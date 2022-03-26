(*     **** New plan for mesh network implementation ****

    ***
        Update-1, using NON? in >DEST and >NODE and HANDLER)
        using CATCH on the HANDLER) and changed SCANX to
        work with any RF-setting
    ***
        Update-2, add RF-settings behind shield
    ***
        Update-3, remove & add unstable node to keep
        the network as fast as possible.
    ***
        Update-4, Add extra RF-data to SETRF and change
        data address in >PAYLOAD & ADD-CONN was 6 'PAY now 5 'PAY
        New version of REGISTER with ask number!!
        Changed READ-RX & XEMIT? and ORG redefined as 2 PAY>
        Refactored !HOP & HOP) is now !HOPS
        Rewitten .STATUS to print real values
        Added REGISTER function to MESH core!
    ***
        Update-5, added trace info for suppressing & releasing nodes
        Changed <MS> to <WAIT>, etc.
        Corrected notation of faulty node when doing indirect access
    ***
        Update-6, integrate dynamic payload
    ***
        Update-7, Risc-V version
    ***
        Update-8, New dynamic payload & rf-error handling implementation
                  Also >F is fixed by repairing READ-DRX?
    ***

                                            1st         2nd    3th
        Basic 24l01 using usci 2021-01-13:  1464 bytes (1520) (1466/1476:1670) Small tools
        Mesh node 4.1:                      2320 bytes (2666) (2880/3220:3364)
        Total:                              3784 bytes (4186) (4346/4696:5034)
        Free with use of small tools:       3728 bytes (3316) (3158/2808:1930)
        Free RAM:                            140 bytes  (130)  (124/122:90)
        With BUILD & demo routines free:                      (ROM=1540, RAM=88)

Dynamic payload format from 1 to 32 bytes:
|   0   |  1  |  2  |    3   |  4  |  5 to 31   |
|-------|-----|-----|--------|-----|------------|
|Command|Dest.|Orig.|Sub node|Admin|d00| to |d1A|

0 pay>  = Command for destination      1 pay>       = Destination node
2 pay>  = Origin node                  3 pay>       = Address of sub node
4 pay>  = Administration byte          5 to 31 pay> = Data 0x1A (#26) bytes

*)

hex
\ Defining this node
 1 constant #TYPE       \ I am a power switch
 0 constant #SUB        \ I contain +n sub nodes
10 constant #N          \ Max. number of nodes used
#n 8 /mod swap 0 > abs + \ Calculate rounded size
   constant #MAP        \ Size of bitmap

\ EXEC handles execution tables, it needs the table address on the
\ stack. Note that, all data needs te be cell aligned. The last command
\ token is always -1 and ERR-XT is then the error recovery routine.
\ Like: CREATE EXEC-TABLE  C0 ,  XT0 ,  C1 , XT1  ...  -1 , ERR-XT ,
\ c = command token, exec-table = start address of execution table
code EXEC   ( c exec-table -- ?? )
  4708 ,  4437 ,  482A ,  5228 ,  933A ,  2402 ,
  970A ,  23FA ,  8328 ,  4437 ,  4826 ,  4630 ,
end-code
code LOC    ( node a -- bit byte-adr ) \ Bit location in byte-addr
  4428 ,  F038 ,  7 ,  431A ,  8318 ,  2802 , 5A0A ,
  3FFC ,  4428 ,  4A84 ,  0 ,  422A ,  831A ,  2402 ,
  1108 ,  3FFC ,  F038 ,  #map 1- ,  5807 ,  next
end-code


\ Node data tables
create USER     #map allot  \ Working BIT-table for APP programmer only!

create WORK     #map allot  \ Scratch BIT-table for internal use
create ALL      #map allot  \ BIT-table with all found nodes
create DIRECT   #map allot  \ BIT-table with direct accessable nodes
create INDIRECT #map allot  \ BIT-table with indirect accessable nodes
create RF-ERROR #map allot  \ Bit-table with failed nodes
create HOPS     #n allot    \ Table with hopping nodes
create TYPES    #n allot    \ Table with node-types

: ZERO  ( a -- )        #map 0 fill ; \ Erase bit-map a
: *SET  ( node a -- )   loc *bis ; \ Add node to a
: *CLR  ( node a -- )   loc *bic ; \ Remove node from a
: GET*  ( node a -- b ) loc bit* ; \ Node present in a?

\ Leave number of nodes found in a bitmap
code COUNT* ( a -- +n ) \ Count noted nodes
    4708 ,  E707 ,  403A ,  #map ,
    4876 ,  1106 ,  6307 ,  9306 ,
    23FC ,  533A ,  23F9 ,  next
end-code

\ Leave node number of the first used node in bitmap & erase it
: NEXT?     ( a -- false | node true )
    #n 0 ?do            \ Test all bits
        i over get* if  \ Node bit set?
            i swap *clr  i true unloop exit
        then
    loop  drop  false ;  \ Nothing found


\ Basic control values
value STOP?     \ Is -1 for stopping programs
value ON?       \ Switch On/Off
value PWR       \ nRF24 scan TX-power
#len 5 - constant #B \ Databuffer size in payload

: ORG       ( -- node ) 2 pay> ;
: .DB       ( +n -- )   3 and  -3 +  6 * .  ." db" ;
: .BITRATE  ( +n -- )   ?dup 0= if ." 250 kBit " exit then . ." Mbit, " ;
: .STATUS   ( -- )
    base @ >r  decimal
    cr ." Node v 4.1 nr: "      \ Show node vsn
    #me . ."  nRF24 "           \ Which node with nRf24
    get-status ?dup if          \ nRF24 not connected?
        E <> if  ." not "  then \ nRF24 not ready?
        ." ok, " rf@ .bitrate   \ Show nRF24 RF settings
        .db  ." , Scan " pwr .db
        ." , RF channel = "  #ch .
    then  r> base ! ;


\ Next big change: Add dynamic payload to SETRF ???
\ NOTE! Rewrite RF settings & node number for nRF24 right behind the shield NODE\
\ Usable range in europe 2400 MHz to 2483 MHz
\ #ch:      Used nRF24 channel number (0 t/m 7D)    ( 125 bands, separation 1 Mhz )
\ scan pwr: 0 = -18db, 1 = -12db, 2 = -6db, 3 = 0db ( Power used to build network )
\ pwr:      0 = -18db, 1 = -12db, 2 = -6db, 3 = 0db ( Communication power )
\ bitrate:  0 = 250 kbit, 1 = 1 Mbit, 2 = 2 Mbit    ( Communication bitrate )
: SETRF     ( #ch scan-pwr pwr bitrate #me -- )
    to #me  set-my-addr     \ Save & init. my node address
    2dup >rf  rf!  to pwr   \ Save RF-settings & scan power
    dup >channel  to #ch    \ Than channel number
    s" NODE\" evaluate      \ Remove previous settings  *** Change shield name if necessary ***
    rf ,  #me ,  pwr ,      \ Compile & save new settings
    #ch ,  freeze ;


\ Switch node states
: RUN       ( -- )      false to stop? ;        \ Allow a program to run free
: HALT      ( -- )      true to stop?  ch ) temit ; \ Stop a program
: HALT?     ( -- )      key?  stop? or  run ;   \ Alternative KEY? to stop node programs
: >USER     ( a -- )    user #map move ;        \ Copy nodes to node accu for app programmer
: >WORK     ( a -- )    work #map move ;        \ Copy node for internal use only
: >PAYLOAD  ( a +n -- ) 5 '>pay +  #map move ;  \ Copy map a to the payload at offset +n


\ Alternative MS routine that waits for answers to commands
value WAIT? \ Exit <<WAIT>> when false
value MS)   \ Decreases 976 times each second
value (MS   \ Remember duration
code INT-ON   ( -- )    D232 ,  next  end-code
\ Clock = 8000000/8192 longest interval 67,10 sec. usable as MS
\ Decrease (ms) until it's zero
create MSTIMER  9382 ,  adr ms) ,  2402 ,  53B2 ,  adr ms) ,  1300 ,
: READY     ( -- )      5A91 120 !  0 to wait? ;                       \ Exit <<WAIT>> loop
: >MS       ( u -- )    5A19 120 !  dup to ms)  to (ms  -1 to wait? ;  \ (Re)start timeout timer
: (MS)      ( -- )      wait? if  ms) ?exit  ch ] temit  ready  then ; \ Timeout controller
mstimer   FFF4 vec!     \ Install watchdog interrupt vector


\ Check any node with an noted RF-ERROR connection, take them
\ into use again when they respond!
\ This command must be executed in quiet periods only.
\ Version with bitmap address on the stack, this may be used
\ to regularly check every node in the network.
: RF-RESTORE    ( a -- )
    2 >len
    dup count* 0= if  drop  norm  exit  then \ No faulty nodes, then ready
    #n 0 ?do                        \ Check all possible nodes
        i over get* if              \ Node marked as suppressed?
            i set-dest  write-mode  \ Yes, activate write mode
            ch } 0 >pay WRITE-DTX? if \ Try connection, succeeded?
                #ch >channel        \ Restore packet loss counters
                i RF-ERROR *clr     \ Yes, release node again
                t? if  i 1 .r ch + emit  then \  Show release of a failed node
            then
            flush-tx  reset
        then
    loop  drop  read-mode  norm ;

: RF-ERROR?     ( node -- flag )    \ Give true if node cannot be found
    dup rf-error get* if            \ Unavailable?
        rf-error rf-restore         \ Yes, try to restore
        rf-error get* 0= exit       \ Succeeded?
    then
    dup - ;                         \ Node available


\ Wait MS milliseconds & respond to external network commands
\ Leave early after an answer command!
value 'HANDLER \ Contains token of HANDLER)
: <<WAIT>>    ( -- )
    read-mode  begin
        irq? if  xkey 'handler execute  then  (ms)  \ Now with HANDLER
    wait? 0= until  read-mode ;

: <WAIT>      ( u -- )
    #fail #retry = if  drop exit  then  >ms <<wait>> ;

(* Optional add restoring lost connections to >DEST or >NODE
   And when used in >NODE it must be build into (HANDLER) too
   at the point where hopping is done
   Then they may already be restored at the next transmission
*)

value NON?  \ True when'node' is a non existing node number!
value HOP#  \ Holds direct hopping node
: >DEST     ( node -- )
    dup FF = if set-dest exit then  \ Is it not a registered node?
    dup indirect get* if            \ Yes, is it a indirect node?
        dup hops + c@  dup set-dest \ Yes, fetch node used for hopping
        to hop#  1 >pay  exit       \ Set dest with correct (hopping) destination
    then
    dup direct get* 0= to non?      \ A direct node, check if node does not exists?
    non? if ."  Unknown node " then \ If so give message!
    set-dest ;

\ New version with releasing of a node when it does not respond
: >NODE     ( node c -- )
    over RF-ERROR? if                   \ Skip node if it was previously unresponsive
        #retry to #fail  2drop  exit    \ Also skip <WAIT> behind it
    then
    swap  t? if  dup 1 .r  then  >dest  \ Set destination
    non? if  drop exit  then  xemit     \ When node unknown, skip XEMIT
    #fail #retry < ?exit  1 '>pay c@    \ No failure, then ready, or leave failed node
    t? if   dup 1 .r ch - emit  then    \  Show suppress of a failed node
    dup direct get* 0=                  \ Not a direct node?
    if drop hop# then  RF-ERROR *set ;  \ Yes, replace with direct hopping node & note failure!

\ Print all noted nodes from a bitmap
: .MAP      ( a -- )
    dup count* 0= if  ." no "  then  ." nodes "
    #n 0 ?do
        i over get* if  i .  then \ Show nodes found
    loop  drop ;


: <INFO     ( -- )          \ len = 5+2
( ) t? if  cr  ." Info>"  org .  then
    #type 5 >pay            \ Node type
    #sub 6 >pay             \ Number of sub nodes, 0 to 9
(   ...  )  7 >len          \ 8 to 12, max. nine sub node types
    org ch @ >node  norm ;  \ Send data back

: INFO>     ( -- )      \ Receive info from other nodes
    5 pay>  org  types + c!  ready ;


\ Add all my connections to the payload! Note that the payload is 4 + 2*table length bytes!
: ADD-CONN  ( -- )
    direct 0 >payload        \ Send my direct table  (2 bytes now)
    indirect #map >payload ; \ & indirect table      (2 bytes now)

\ Return 'H' answer, the nr of direct nodes and the bitmap of these nodes
\ The maximum size of the table now is six bytes (48 nodes) due to the length
\ of the usable payload of 12-bytes in the current payload of 17-bytes!!
: <HOP      ( -- )
    ch H temit add-conn  9 >len \ Send my direct table & indirect table (len=5+4)
    org ch ^ >node  norm ;

: !HOPS     ( a -- )            \ Extend my indirect node tables
    begin  dup next? while      \ Node found in table 'a'
        dup all get* 0= if      \ Not yet present?
            dup indirect *set   \ Note an indirect node
            dup all *set        \ Extend all nodes table too
            org over hops + c!  \ Finally note HOPping node
            t? if               \ Show hop found
                cr ." Node " org . ." hop to " dup .
            then
        then  drop
    repeat  drop ;

: HOP>      ( -- )
    5 'pay> !hops                 \ Direct node data
    5 'pay> #map + !hops  ready ; \ Indirect node data


create DATA-BUFFER #map 2* allot
: <OK       ( -- )       \ Return '}' answer to origin node (len=5+4)
    9 >len  add-conn  org ch } >node  norm ;

: PING>     ( -- )
    5 'pay>  data-buffer 4 move \ Copy received data 
    ms) negate +to (ms  ready ; \ Receive PING response

\ Registration of new unregistered nodes
: <GIVE-NO. ( -- )              \ This is network data command 'N' (5+1)
    6 >len  #n 0 ?do
        i all get* 0= if        \ Free node number found?
\ )         cr ." No. " i .
            i 5 >pay            \ Yes, set number ready
            org ch # >node      \ and send it back to the requesting node
            unloop  norm  exit  \ ready
        then
    loop
    FF 5 >pay  org ch # >node  norm ; \ No, all node numbers are occupied

: GET-NO.>  ( -- )              \ This is node data command '#'
    5 pay> FF = ?abort          \ Abort if there are no more node numbers available
\   cr ." No. " 5 pay> .
    5 pay> to #me  ready ;      \ Replace node number

: REGISTER> ( -- )      \ Handle the registration of a new node
    org all get* ?exit  \ Already present, then we are ready
    org all *set        \ Register the new node
    org direct *set     \ It's a direct node ofcourse!
    5 'pay> !hops ;     \ Add possible but unlikely new indirect nodes

: SIGN-UP   ( -- )      \ Copy #ME & NEW nodes table to blend into a network
    direct >work  7 >len  \ Add myself to all direct accessable nodes
    begin  work next? while \ Use direct nodes
        direct 0 >payload  ch R >node \ Copy NEW nodes table to direct neighbours
    repeat  norm ;

: .NODES    ( -- )
    cr ."      All " all .map        \ Show all found nodes
    cr ."   Direct " direct .map
    cr ." Indirect " indirect .map ;

: .ALL      ( -- )
    .nodes
    cr ." RF-error " rf-error .map
    cr ."     Node types "  #n 0 ?do  i all get* if types i + c@ . then  loop
    cr ."     Hop route: "  indirect >work
    begin  work next? while  dup .  hops + c@ . space  repeat ;

\ Set a node table ready apart from myself
: >WORK-ME    ( a -- )      >work  #me work *clr ;

: DELETE-MESH ( -- )
    all zero  direct zero   rf-error zero \ Clear node administration
    indirect zero  types #n 0 fill ; \ Empty type table

: >NODES    ( c ms -- )      \ Send node command to all nodes noted in WORK
    >r  begin  work next? while  over >node  r@ <wait>  repeat
    drop  rdrop  0 to #fail ;

\ DN: use shortest payload length (2)
\ 0 scan = max. 4 meters  ( 1 wall )    2 scan = max. 10 meters ( 1 wall )
\ 4 scan = max. 10 meters ( 2 walls )   6 scan = max. .. meters ( .. )
: SCANX     ( -- )
    2 >len  t? if cr pwr .db ."  sx " then \ Show scan power
    pwr rf@ nip >rf                 \ Set scan power
    delete-mesh  #n for             \ Scan all nodes
        i set-dest  write-mode      \ Set node address
        ch | 0 >pay  WRITE-DTX? if  \ Send command, ACK received?
            #ch >channel            \ Reset nRF24 channel
            i all *set  i direct *set \ Note this node
            t? if  i 1 .r  ." + "  then \ Show addition
        then
        flush-tx  reset             \ Restore nRF24
    next  norm  read-mode rf@ >rf ; \ Restore normal RF power

: >OTHERS   ( c -- )    80 >nodes ;
: *SCANX    ( -- )      scanx  org ch } >node ;
: HOP       ( -- )      all >work-me  ch H >others  .nodes ;
: INFO      ( -- )      all >work  ch I >others  .all ;


\ Handle commands & scripts
: COMM-ERROR ( -- )
\   Optional send back an error token and some data!  *WO*
\   0 pay>  5 >pay  org ch ? >node      \ Return an error token & invalid command as data
    t? if  cr ." Comm. error " .s  then \ Signal error
    setup24l01  read-mode ;

v: inside also
\ Receive and execute commands from another node
: OUTPUTON  ( -- )      -1 to on?  power-on   <ok ;
: OUTPUTOFF ( -- )      0 to on?   power-off  <ok ;
: FORTH>    ( -- ?? )   5 'pay>  4 pay>  evaluate  ready  .ok ;


\ Node commands, since all nodes are equal each node
\ must be able to send and receive commands.
create 'COMMANDS    ( -- addr )
  ( Execute generic commands )
    ch F ,  ' forth> ,      \ Execute (Run) Forth command
    ch | ,  ' halt ,        \ Stop any free running program
  ( Execute target specific commands )
    ch * ,  ' outputon ,    \ Activate output
    ch _ ,  ' outputoff ,   \ Deactivate output
  ( Give back some network data )
    ch I ,  ' <info ,       \ Give node info back
    ch H ,  ' <hop ,        \ Give my direct nodes back
    ch P ,  ' <ok ,         \ Respond on ping
    ch N ,  ' <give-no. ,   \ Give free node number back
  ( Gather network data actively )
    ch s ,  ' *scanx ,      \ Scan network, with finish message
    ch i ,  ' info ,        \ Gather node info
    ch h ,  ' hop ,         \ Ask direct nodes of neighbours
  ( Receive node data )
    ch ^ ,  ' hop> ,        \ Receive HOP data
    ch @ ,  ' info> ,       \ Receive node info
    ch R ,  ' register> ,   \ Add a new node to the network
    ch } ,  ' ping> ,       \ Receive ping (external command finished)
    ch # ,  ' get-no.> ,    \ Receive & save free node number
\   ch ? ,  ' ping> ,       \ Note an error response  *WO*
  ( Finish )
    -1 ,    ' comm-error ,  \ Message on an command error
    align


\ Commands to other nodes directly
: ON        ( node -- )     ch * >node 40 <wait> ; \ Send power on command
: OFF       ( node -- )     ch _ >node 40 <wait> ; \ Send power off command
: STOP      ( node -- )     ch | >node 40 <wait> ; \ Stop external Forth program
: ALL-ON    ( -- )          all >work  ch * 40 >nodes ;
: ALL-OFF   ( -- )          all >work  ch _ 40 >nodes ;
: STOPALL   ( -- )          all >work  ch | 40 >nodes ;


: SWITCH?   ( -- flag )         \ Handle switch event
    s? if  key? exit  then      \ No keypress, check terminal key
    begin  40 <wait> s? until   \ Short keypress only
    on? if all-off else all-on then  false ;

: (HANDLER)  ( c -- )
    1 pay> #me = if         \ Packet for me?
        'commands exec      \ Yes, execute command
    else
        1 pay> rf-error? 0= if
            mlen >len                   \ Original payload length
            1 pay> t? if dup 1 .r then >dest \ No, fetch & set hop destination
            'read 'write mlen move      \ Copy RX- to TX-payload
            org 2 >pay                  \ Use same origin
            non? 0= if                  \ Node known?
                dup xemit  ch > temit   \ Yes, relay packet, print hop symbol
            then
        then  drop  norm                \ Restore payload length
    then  read-mode ;

: HANDLER)  ( c -- )
    ['] (handler) catch if  drop  setup24l01  read-mode  then ;

: HANDLER?  ( -- flag )     \ Handle all node data & commands
    irq? if                 \ Payload packet received?
        xkey handler) false \ Yes, get it
    else                    \ No, own command
        wait? ?dup 0= if
            ( event? )  switch?
        then
    then  (ms)  led-off ;

: XKEY)     ( -- c )    begin  handler? until  key) ;

chere  -1 ,  to #me     \ Headerless node data address
: STARTNODE ( -- )      \ Initialise node, with tracer on, change to TROFF in startup
    [ #me ] literal @           \ Fetch RF data address
    @+ to rf  @+ to #me         \ Get & set RF mode and node number too
    @+ to pwr  @ to #ch         \ Set scan power & used channel number
    delete-mesh  spi-setup      \ Activate B0 SPI interface
    5 ms  setup24L01            \ Wakeup & init. nRF24
    #me set-dest  run           \ Init. addresses & to run mode
    .status  tron               \ Print status, tracer on
    power-off  0 to on?
    ready  1 0 *bis  int-on     \ IE1  Activate <WAIT>
    ['] handler)  to 'handler   \ Add NODE handler to <<WAIT>>
    ['] xkey)  to 'key  read-mode ; \ Add KEY & node handler to KEY


\ Send Forth command string of max. #LEN-5 bytes to remote node
: >F)       ( node a u -- ) \ Send string a u to node
    #len >len  >r r@ 4 >pay \ Max. payload, string length to admin byte
    5 '>pay r> #b umin move \ Copy command to payload
    ch F >node  norm ;      \ Send command

: >F        ( node ccc -- ) 0 parse  >f) ;

: >ALL      ( a u -- )      \ Send string a u to all nodes
    2>r  all >work-me       \ Do send to all but myself
    begin  work next? while  2r@ >f)  repeat
    cr  2r> evaluate ;      \ Execute string on myself


: INFO?     ( -- f )        \ 'f' is true when all info is gathered
    -1  all >work
    begin  work next? while
        types + c@ 0<> and
    repeat ;

: FINISH    ( -- )
    4 for
        info cr  all >work-me  ch i >others \ Gather all node information
        #me ch I >node 40 <wait> \ Finally on myself & ready
        info? if rdrop exit then \ Ready when all info is gathered
    next ;

: REGISTER  ( -- )              \ Register a single node to the mesh network
    ." From " .status           \ Show nRF24 status
    #me FF <> ?exit  scanx  cr  \ Exit when not FF
    direct >work work next? 0= ?abort \ Get first occupied node number?
    cr  ch N >node  40 <wait>   \ Yes ask first free node there
    #ch  pwr  rf@  #me setrf    \ Renew node with received number and current RF-settings
    sign-up  cr  hop  cr        \ Add my node to the network do HOP
    all >work-me  ch h >others cr finish ; \ on myself & all direct found nodes


( Add your own application here )




' startnode  to app   v: fresh
shield NODE\   troff  ( Tracer off )

chere  #me ROM!     \ Store address RF data

spi-setup           \ Activate SPI interface
55 1  3 1  FF setrf \ Default RF value & node number, etc.

' 24l01\ ' tools\ - dm .  ( Basic )
' node\  ' 24l01\ - dm .  ( Mesh )
' node\  ' tools\ - dm .  ( All )
ivecs chere - dm .  ( Free flash )
tib here - dm .     ( Free ram )

cold
