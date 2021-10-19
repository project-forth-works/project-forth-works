\   Filename: sdcard.fs
\    Purpose: access sdcard via spi1 bit banging
\        MCU: GD32VF103
\      Board: * , tested with Logan Nano
\       Core: Mecrisp-Quintus 0.27 by Matthias Koch.
\   Required: Mecrisp-Quintus >= 0.27
\     Author: Matthias Koch
\      Date : Jun 2020
\   Requiers: registernames.fs
\ Literature: https://www.convict.lu/pdf/ProdManualSDCardv1.9.pdf
\    Licence: GPLv3
\  Changelog:
\ 2020-07-31:  MaBi002 added "noanswer?"
\ 2020-08-01:  MaBi003 added sd-error?
\ 2020-08-01:  MaBi004 corrected typo in sd-erase
\ 2020-08-18:  MaBi005 renamed sd-error? to sd-exit for multilevel exits
\ 2020-08-19:  MaBi006 correctet error in sd-read


\ ==============================================================================
\ Usage of the error handlers:

\ There are three levels of error handling. Level 0 is a classic 'message and
\ leave' level. It tells the reason why it leaves and performs a quit that will
\ bring you back to the highest (or lowest; depends on the point of view)
\ interpreter level. Level 1 will show a message and level 2 won't. Both levels
\ will do a multilevel exit. That is: They will jump to the level that was saved
\ by a 'catch' done before. The purpose if this is as follow: You will be able
\ to do calls for SD Card functions and in case of failure nothing will
\ happen. Think of a program running for 'ever' doing something important (of
\ course it does!) and logging some data by the way. What happens if the SD Card
\ runs out of memory? Will this failure 'freeze' your very important program? It
\ will if there is no error handling. It will also if you choose error level 0
\ (message and quit), but it won't if you choose error levels 1 or 2. Nothing
\ will disturb the running program. Of course some data will not be stored to
\ the SD Card or read from the SD Card. If you want to inspect the error later
\ on there is a variable last-error that holds the number of last invoked error.
\ ==============================================================================

\ -------------------------------------------------------------
\   Leitungen für die SPI-Schnittstelle definieren
\ -------------------------------------------------------------


1 12 lshift constant CS_TF  \ GD_PB12
1 13 lshift constant SCLK   \ GD_PB13
1 14 lshift constant MISO   \ GD_PB14
1 15 lshift constant MOSI   \ GD_PB15

: miso@ ( -- 0|1) GPIOB_ISTAT @  MISO and 14 rshift ;

: sclk-high    SCLK  GPIOB_BOP h! ;
: sclk-low     SCLK  GPIOB_BC  h! ;

: mosi-high    MOSI  GPIOB_BOP h! ;
: mosi-low     MOSI  GPIOB_BC  h! ;

: -spi1 ( -- )  CS_TF GPIOB_BOP h! ; \ deselect SPI
: +spi1 ( -- )  CS_TF GPIOB_BC  h! ; \ select SPI

: spi-init ( -- )
  $14114444 GPIOB_CTL1 !  \ Set PB12, PB13 and PB15 as output, PB14 as input.
   -spi1  sclk-low  mosi-high \ Fürs Reset benötigter Ruhezustand: /CS and DI=MOSI high, Clock low.
;

\ -------------------------------------------------------------
\   Leitungen prüfen
\ -------------------------------------------------------------

\ : b-sclk spi-init begin sclk-high 1000000 0 do loop sclk-low 1000000 0 do loop key? until ;
\ : b-mosi spi-init begin mosi-high 1000000 0 do loop mosi-low 1000000 0 do loop key? until ;
\ : b-cs   spi-init begin -spi      1000000 0 do loop +spi     1000000 0 do loop key? until ;
\ : s-miso spi-init begin miso hex. cr key? until ;

\ -------------------------------------------------------------
\   Kommunikation über die SPI-Leitungen
\ -------------------------------------------------------------

: >spi> ( c -- c )  \ bit-banged SPI, 8 bits
  8 0 do
    dup $80 and if  mosi-high else  mosi-low then
     sclk-high
    2*  miso@ or
     sclk-low
  loop

  $FF and ;

\ Single byte transfers

: spi> ( -- c ) $FF   >spi> ;  \ read byte from SPI
: >spi ( c -- )  >spi> drop ;  \ write byte to SPI

\ ==============================================================================
\ Errorhandling Errornumbers from SD card are in range of 2-255. MaBi005
\ ==============================================================================

\ I use the catch throw mecanism. Catch and throw lived in common/mulitask.fs. I
\ made slightly canges: don't care about multitasker; give warning if throw is
\ used without a preceeded catch.

0 Variable handler

: quit ( -- )  \ quit takes care of handler
  0 handler ! quit
; 

: catch ( x1 .. xn xt -- y1 .. yn throwcode / z1 .. zm 0 )
  (do) \ push I and I'
  sp@ >r handler @ >r rp@ handler !  execute
  r> handler !  rdrop  0 unloop ;

: throw ( throwcode -- )
  dup
  IF
    handler @ 0=
    IF \ unhandled error: quit MaBi
      ." Throw without catch! Quit!" quit
    THEN 
    handler @ rp! r> handler ! r> swap >r sp! drop r>
    UNLOOP  EXIT
  ELSE
    drop
  THEN ;

  
\ I take in account three types of error:
\ - card saying there is an error (2-254),
\ - no respond from card (256)
\ - This is no error: empty answer (255)
\ so all 'valid' errors are in the range 2-256


1 Variable sd-error-verbose-level \ 0=verbose and quit, 1=verbose, 2=silent
0 Variable last-error

: sd-error-level+- ( n -- ) \ change verbosity of SD card errormessages
  sd-error-verbose-level
  dup @ rot + 3 mod
  swap !
;

: sd-error-level+ ( n -- ) \ increase verbosity of SD card errormessages
  1 sd-error-level+-
;

: sd-error-level- ( n -- ) \ increase verbosity of SD card errormessages  
  -1 sd-error-level+-
;

: sd-error-level? ( -- ) \ show error level
  sd-error-verbose-level @
  CASE
   0 OF ." Verbose and quit!" ENDOF
   1 OF ." Verbose exit!" ENDOF
   2 OF ." Silent exit!" ENDOF    
    drop
  ENDCASE
;
  
: error$! ( n / string -- )
  [char] " parse rot , string,
;


\ this list is a "null terminated" list

Create error$
$100 error$! No answer from SPI! Missing SD Card or Initialisation!"
2 error$! Card is idle!"
4 error$! Erase command beyond border!"
8 error$! Illegal command!"
16 error$! CRC Error!"
32 error$! Wrong sequence of erase commands!"
64 error$! Misaligned address!"
128 error$! Wrong parameter (blocknumber?)!"
0 , \ error$! Out of error list!"


: error. ( n -- )
  error$
  BEGIN
    2dup @
  WHILE
      over @ and 
      IF
        cr dup cell+ count type
      THEN
      cell+ count + even
  REPEAT
  2drop
;  

: sd-error. ( f -- f )
  sd-error-verbose-level @
  2 <>
  IF error. THEN
;

: sd-exit ( n -- n )
  dup
  dup last-error !
  $1FE and over 255 <> and 
  IF
    sd-error-verbose-level @
    IF
      sd-error. throw
    ELSE
      sd-error. quit
    THEN
  THEN
;
  
0 Variable answer#  \ MaBi002

: noanswer? ( n -- flag )  \ MaBi005
  answer# @ <            
  1 answer# +!
  IF $100 sd-exit THEN
;


\ end of error handling routines
\ ==============================================================================


\ ==============================================================================
\   Kommunikation mit der SD-Karte
\ ==============================================================================

0 variable crc

: (sd-cmd) ( arg cmd -- u )
  2 us
   +spi1
            $FF  >spi
         $40 or  >spi \ Command
  dup 24 rshift  >spi \ Argument, 32 Bits, 31-24
  dup 16 rshift  >spi \ 23-16
  dup  8 rshift  >spi \ 15-8
                 >spi \ 7-0
          crc @  >spi \ CRC-Feld, welches bei SPI-Schnittstelle nur für den ersten Befehl gebraucht und sonst ignoriert wird.

  0 answer# ! \ MaBi002
  begin $FF    \ Auf die Antwort von der SD-Karte warten 
    10 noanswer?   \ MaBi005
    >spi>
    sd-exit \ MaBi005
    dup $80 and
  while drop
  repeat 
;

: sd-cmd ( arg cmd -- u ) (sd-cmd) -spi1 ;

512 buffer: sd.buf

: sd-copy ( f n -- )
  swap
  begin
    $FE <>
  while $FF  >spi> 
  repeat
  0 do
    $FF  >spi> sd.buf i + c!
  loop
  $FF dup  >spi  >spi
;

: sd-cmd-r3-r7 ( arg cmd -- u response )
  (sd-cmd)

   spi>    8 lshift
   spi> or 8 lshift
   spi> or 8 lshift
   spi> or

   -spi1
;

: sd-cmd-r2 ( arg cmd -- u ) \ 17-Bytes lange Antwort, die ersten 16 davon im Puffer zuückgeben.
  (sd-cmd)
  16 sd-copy
   -spi1
;

\ -------------------------------------------------------------
\   Größe der Karte bestimmen
\ -------------------------------------------------------------

0 variable #sd-blocks

: read-sd-size ( -- )  \ Return card size in 512-byte blocks

  0 9 sd-cmd-r2 \ Send CSD

  sd.buf 7 + c@    8 lshift
  sd.buf 8 + c@ or 8 lshift
  sd.buf 9 + c@ or
  1+ 10 lshift

  #sd-blocks ! \ Zahl der Blöcke speichern
;

: sd-size ( -- u ) #sd-blocks @ ;

\ -------------------------------------------------------------
\   Initialisierung
\ -------------------------------------------------------------

: sd-init ( -- )  \ Initialize card, show messages
   spi-init
  100 ms

  10 0 do $FF  >spi loop \ Mindestens 74 Taktpulse mit /CS high

  begin
    $95 crc ! 0 0 sd-cmd  \ CMD0 go idle
  $01 = until

  1 crc !
  0 59 sd-cmd drop \ CRC off

  ." SD-Card type: "
  $87 crc ! $1AA 8 sd-cmd-r3-r7 hex. dup hex. 1 =

  if \ Ver 2.00 or later SD Memory Card

    begin
              0 55 sd-cmd drop \ Es folgt einer der ACMD-Kommandos
      $40000000 41 sd-cmd       \ ACMD41, mit HCS=1, da wir hier hohe Kapazitäten unterstützen
    0= until

    0 58 sd-cmd-r3-r7 ." OCR: " hex. hex. \ Read OCR register. Das ist ein R3-Antworttyp, aber die haben die gleiche Länge.

    512 16 sd-cmd ?dup if ." Wrong block size: " hex. then \ Blockgröße auf 512 Bytes setzen

    read-sd-size
  else
    ." Ver 1.X SD Memory Card or not SD Memory Card" cr
    exit
  then

  ." with " sd-size hex.
  ." blocks or " sd-size 2/ 1024 / .
  ." MB initialised." cr
;

\ MaBi005
: sd-init ( -- )  \ define cached sd-init over old sd-init
  ['] sd-init catch drop ;


: sd-init-silent ( -- )  \ Same as sd-init but silent mode (no messages)
   spi-init
  100 ms

  10 0 do $FF  >spi loop \ Mindestens 74 Taktpulse mit /CS high

  begin
    $95 crc ! 0 0 sd-cmd  \ CMD0 go idle
  $01 = until

  1 crc !
  0 59 sd-cmd drop \ CRC off

  $86 crc ! $1AA 8 sd-cmd-r3-r7 drop 1 =

  if \ Ver 2.00 or later Memory Card

    begin
              0 55 sd-cmd drop \ Es folgt einer der ACMD-Kommandos
      $40000000 41 sd-cmd       \ ACMD41, mit HCS=1, da wir hier hohe Kapazitäten unterstützen
    0= until

    0 58 sd-cmd-r3-r7 drop drop \ Read OCR register. Das ist ein R3-Antworttyp, aber die haben die gleiche Länge.

    512 16 sd-cmd ?dup if ( error: wrong block size ) drop then \ Blockgröße auf 512 Bytes setzen

    read-sd-size

  else
    ( error: Ver 1.X Memory Card or not an Memory Card )
    exit
  then

  ( no error?. card is initialized )
;

\ MaBi005
: sd-init-silent ( -- )  \ define cached sd-init-silent over old sd-init-silent
  ['] sd-init-silent catch drop
;


\ -------------------------------------------------------------
\   Identifikation anzeigen
\ -------------------------------------------------------------

\ : show-sd-size ( -- )
\   0 9 sd-cmd-r2 \ Send CSD
\   sd.buf 16 dump
\ ;

: show-sd-size ( -- )  \ MaBi005
  0 9 ['] sd-cmd-r2 catch
  \ 0=
  IF
    2drop
  ELSE    
    sd.buf 16 dump
  THEN
;

\ : show-sd-id ( -- )
\   0 10 sd-cmd-r2 \ Send CID
\   sd.buf 16 dump
\ ;

: show-sd-id ( -- )  \ MaBi005
  0 10 ['] sd-cmd-r2 catch \ Send CID
 \ 0=
  IF
    2drop
  ELSE    
    sd.buf 16 dump
  THEN
;
\

\ -------------------------------------------------------------
\   Block lesen und schreiben
\ -------------------------------------------------------------

: sd-read ( block -- ) \ Einen 512-Byte-Block von der SD-Karte lesen
  17 (sd-cmd) \ Single block read
  512 sd-copy
  -spi1
;

\ MaBi006
: sd-read ( block -- )  \ define cached sd-read over old sd-read
  ['] sd-read catch IF drop THEN \ MaBi006
  -spi1
;

: sd-write ( block -- ) \ Einen 512-Byte-Block auf die SD-Karte schreiben
  24 (sd-cmd) 
    
  $FE  >spi   \ DATA_START_BLOCK


  512 0 do
    sd.buf i + c@  >spi 
  loop

   spi> drop  spi> drop \ ." CRC " spi> 8 lshift spi> or hex. \ Data response
  begin  spi> $FF = until \ Warte, bis Busy-Flag verschwindet
  -spi1
  \ THEN
;

\ MaBi005
: sd-write ( block -- )  \ define cached sd-write over old sd-write
  ['] sd-write catch  2drop
  -spi1
;


\ -------------------------------------------------------------
\   Alles löschen
\ -------------------------------------------------------------

: sd-erase ( -- )
           0 32  sd-cmd ( sd-error?. ) hex. \ Startblock fürs Löschen
  sd-size 1- 33  sd-cmd ( sd-error?. ) hex. \   Endblock MaBi004

        0 38 (sd-cmd) ( sd-error?. ) hex. \ Löschen ausführen
  begin  spi> $FF = until \ Warte, bis Busy-Flag verschwindet
   -spi1
;

\ MaBi005
: sd-erase ( -- )  \ define cached sd-erase over old sd-erase
  ['] sd-erase catch drop
;


\ -------------------------------------------------------------
\   Ausprobieren
\ -------------------------------------------------------------

: db ( -- ) sd.buf 512 dump ;  \ Dump sector buffer to screen

: view ( u -- ) sd-read db ;  \ Read sector u and dump to screen

: sector-empty? ( -- flag )  \ Test if sector is completely filled with zeros
  true  \ assume that sector is empty
  512 0
  do
    sd.buf i + 
    @ 0<>
    if
      drop false leave  \ sector is not empty 
    then
  4
  +loop
;

: n-view ( limit-sector start-sector -- )
         \ Prints content of a number of sectors that are not empty.
         \ If empty, only the sector number is printed.
         \ Example: 9000 8192 n-view
         \ Reads in sectors 8192-8999 and shows content or sectornumber only.
  cr
  do
    i sd-read
    sector-empty?
    if
      i .
    else
      cr i .  i view cr
    then
  loop
;

: pattern1 ( -- )
  512 0 do i i sd.buf + c! loop
;

: pattern2 ( -- )
  512 0 do i 1 rshift i sd.buf + c! loop
;

: empty ( -- )
  sd.buf 512 0 fill
;


\ sd-init      \ Muss als erstes aufgerufen werden
\ 10 0 n-view  \ Die ersten 10 Sektoren lesen und wenn nicht leer, dann anzeigen

\ ==============================================================================
\ some tests MaBi
\ ==============================================================================

0 Variable parameter

\ : cs ( many -- )  \ cs is clear stack
\   depth 0
\   DO drop
\   LOOP
\ ;
  
\ : t ( xt n -- ?? ) \ calls the xt with parameter n; runs through all error levels 
\   parameter !
\   ' pad !
\   0 sd-error-verbose-level !
\   3 0 DO
\     cr
\     cs 1 2 parameter @
\     cr sd-error-verbose-level @ ." Error level: " 1+ . 
\     sd-error-level+
\     pad @ execute cr ." … … … " ." Stack: " .s
\   LOOP
\   cr
\ ;

\ Try the following code with an inserted SD Card and with an empty SD slot

\ 1 t sd-init \ doesn't need a parameter, but 't' does.
\ 1 t sd-write
\ 1 t sd-read
\ -1 t sd-write
\ -1 t sd-read
\ 1 t sd-erase \ doesn't need a parameter, but 't' does.

    
      