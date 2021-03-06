\ basic assembler for ARM32 from ARMv8
\ (C) J.J. Hoekstra - 2021
\ subset of wabiForth Assembler ARMv8_v21



\ -----------------------------------------------\
\              general assembler words           \
\ -----------------------------------------------\


0 value CONBITS                         \ contains the conditional execution bits
0 value IMMBIT                          \ flags immediate or register based - 0x1 => imm is used
0 value REGBIT                          \ flags reg based offset for LoadStore - 0x1 => reg is used
0 value REGBITS                         \ for the regs in block load and store - has different reset from REGBIT
0 value SHFTBITS                        \ value for shift on operand_2 and used for other purposes
0 value OFFBITS                         \ bits offset for Load and Store
0 value INDBITS                         \ bits for indexing-bits of the Load/Store opcode
0 value DEBUG?                          \ debug flag

: BITFLD ( n opc lsl -- opc ) rot swap lshift or ;

: PUTCOND ( opc -- opc )   conbits 28 lshift or ;
: PUTIMM ( opc -- opc )    immbit 25 lshift or ;
: PUTIMMHW ( opc -- opc )  immbit 22 lshift or ;
: I#, 1 to immbit ;

: OPCODERESET ( -- )                    \ resets flags for next opcode - now in wabiSystem
    14 to conbits
     0 to immbit
     0 to shftbits
     0 to offbits
     [ hex 1800000 decimal ] literal to indbits
     0 to regbit ;

: EOFOPC ( -- )                         \ resets flags for next opcode - handles debug
    debug? if dup ." ,: " .hex then , opcodereset ;

create LBLTBL 16 cells allot            \ table for label-addresses
: CLRLBLTBL lbltbl 16 0 fill ;

: ASM[ opcodereset clrlbltbl ;          \ inits assembler
    immediate

: REG ( n -- ) create , does> @ ;
 0 reg r0,    1 reg r1,     2 reg r2,    3 reg r3,     4 reg r4,     5 reg r5,
 6 reg r6,    7 reg r7,     8 reg r8,    9 reg r9,    10 reg r10,   11 reg r11,
12 reg r12,  13 reg r13,   13 reg sp,   14 reg r14,   14 reg lr,    15 reg r15,
15 reg pc,

\ wabiForth specific internal register-names - only for easier exchange of examples
 5 reg top,			\ top of stack
 6 reg fps,			\ float point stackpointer
 7 reg loopi,		\ do...loop index
 8 reg looplim,		\ do...loop limit
 9 reg dts,			\ datastack pointer
10 reg uss,			\ user return stack pointer
11 reg v,			\ scratch reg for primitives
12 reg w,			\ scratch reg for primitives


: COND ( n -- ) create , does> @ to conbits ;
 0 cond eq,  1 cond ne,  2 cond cs,  2 cond hs,  3 cond cc,  3 cond lo,
 4 cond mi,  5 cond pl,  6 cond vs,  7 cond vc,  8 cond hi,  9 cond ls,
10 cond ge, 11 cond lt, 12 cond gt, 13 cond le, 14 cond al,


\ -----------------------------------------------\
\              Data processing opcodes           \
\          including conditional execution       \
\ -----------------------------------------------\

: SHFT# ( n -- )
    create , does> @ 4 lshift swap      \ immediate shift
    7 lshift or to shftbits ;           \ put imm into shiftbits
: SHFTR ( n -- )
    create , does> @ 4 lshift swap      \ register shift
    8 lshift or to shftbits ;           \ put reg into shiftbits

 0 shft# lsl#,   2 shft# lsr#,   4 shft# asr#,   6 shft# ror#,  \ imm - for data & LDR/STR
 1 shftr lslr,   3 shftr lsrr,   5 shftr asrr,   7 shftr rorr,  \ reg - only for data

: PUTOP2 ( r opc -- opc OR n m opc -- opc )
    or                                  \ reg_operand_2 or 8bit immediate
    shftbits or                         \ or in the shiftbits (if 0= -> nothing happens)
    immbit if 8 bitfld then ;           \ rotate part of immediate

: PUT3REGS ( r r r opc -- opc OR r r n m opc -- opc )
    putop2 16 bitfld 12 bitfld ;        \ operand_2 - operand_1 - destination reg
: PUT2REGS ( r r  opc -- opc OR r n m opc -- opc )
    putop2 12 bitfld ;                  \ operand_2 - destination reg;
: PUTTREGS ( r r opc -- opc  OR r n m opc - opc)
    putop2 16 bitfld ;                  \ operand 2 - operand 1

: (3ROP ( n -- ) create , does> @ putcond putimm put3regs eofopc ; \ 3 register opcode
: (2ROP ( n -- ) create , does> @ putcond putimm put2regs eofopc ; \ 2 register opcode
: (TSOP ( n -- ) create , does> @ putcond putimm puttregs eofopc ; \ comparing opcode

hex  000000 (3rop and,   200000 (3rop eor,   400000 (3rop sub,   600000 (3rop rsb,
     800000 (3rop add,   A00000 (3rop adc,   C00000 (3rop sbc,   E00000 (3rop rsc,
    1100000 (tsop tst,  1300000 (tsop teq,  1500000 (tsop cmp,  1700000 (tsop cmn,
    1800000 (3rop orr,  1A00000 (2rop mov,  1C00000 (3rop bic,  1E00000 (2rop mvn,

     100000 (3rop ands,  300000 (3rop eors,  500000 (3rop subs,  700000 (3rop rsbs,
     900000 (3rop adds,  B00000 (3rop adcs,  D00000 (3rop sbcs,  F00000 (3rop rscs,
    1900000 (3rop orrs, 1B00000 (2rop movs, 1D00000 (3rop bics, 1F00000 (2rop mvns,

    6A00010 (3rop ssat,  6E00010 (3rop usat,
    6800010 (3rop pkhbt, 6800050 (3rop pkhtb,
decimal




\ -----------------------------------------------\
\                    Load-Store                  \
\ -----------------------------------------------\

: PUTREGSLS ( r r opc -- opc )
    shftbits or offbits or                      \ offset imm or reg into operand 2
    indbits or                                  \ bits for offset mode of the indexing
    regbit if 0 bitfld then                     \ put reg in 3:0 for reg-based offset
    16 bitfld 12 bitfld ;                       \ operand_1 - destination reg

: ROFF ( n -- ) create , does> @ to indbits     \ offset Load/Store - reg ->
        1 to regbit 0 to immbit ;               \ regbit=1 to flag use of reg for offset
: IOFF ( n -- ) create , does> @ to indbits     \ offset Load/Store - imm
        0 to regbit 1 to immbit to offbits ;    \ puts immediate in offbits
hex
        3800000 roff +],    3000000 roff -],    \ register
        3A00000 roff +]!,   3200000 roff -]!,   \ expects reg, shift and amount
        2A00000 roff ]+!,   2200000 roff ]-!,   \ in offbits

        1800000 ioff i+],   1000000 ioff i-],   \ immediate - expects 12b offset on stack
        1A00000 ioff i+]!,  1200000 ioff i-]!,  \ 8b offset for LDRD
        0A00000 ioff ]i+!,  0200000 ioff ]i-!,

: (LOST ( n -- ) create , does> @ putcond putregsls eofopc ;
        4100000 (lost ldr,      4000000 (lost str,
        4500000 (lost ldrb,     4400000 (lost strb,

        4300000 (lost ldrt,     4200000 (lost strt,
        4700000 (lost ldrbt,    4600000 (lost strbt,
decimal


\ -- 1reg 16b IMM opcodes -----
hex
: put1reg16imm ( reg, imm16b, opc -- opc )
	swap dup >r FFF and swap
	0 bitfld					\ lower 12 bits of 16b imm
	r> F000 and C rshift swap
	10 bitfld					\ upper 4 bits of 16b imm at bit<16> and higher
	C bitfld					\ Rd
;	 decimal
: (0R16 create , does> @ putcond put1reg16imm eofopc ;
hex	03400000 (0r16 movt,	03000000 (0r16 movw, decimal


\ -----------------------------------------------\
\            Branches & linked Branches          \
\ -----------------------------------------------\

: bx,  [hex] 012FFF10 [decimal] putcond 0 bitfld eofopc ;  \ branch and exchange
: blx, [hex] 012FFF30 [decimal] putcond 0 bitfld eofopc ;  \ link-branch and exchange


: LBL@ ( lbl# -- addr ) cells lbltbl + @ ;
: LBL! ( n lbl# -- ) cells lbltbl + ! ;
: BOFFSET ( dest sourc -- 24b_offset )  \ incl pipeline correction
    8 + - 6 lshift 8 rshift ;

: LBL[ clrlbltbl ; immediate

hex
: CALCADDR ( old_address opcode+offset - next_address )
    FFFFFF and                          \ ( addr lnk_to_addr<23:0> )
    8 lshift 8 arshift                  \ this is a extend_sign for 24 bits
    dup 0<> if
        cells +                         \ ( addr+lnk_to_addr*4 )
    else nip then ;                     \ get rid of old_address under the 0x0

0 value ORIGVAL                         \ contained in the offsetbits of the not-yet-resolved branch
: RESOLVE) ( addr -- )                  \ actual resolution of jumps in a linked list
    begin
        >r                              \ safe addr for later use
        r@ @ 1 bitclear
        to origval                      \ original value for later use by calcadrr

        here r@ boffset                 \ get offset-bits - dest source
        origval                         \ contains opcode-code
        FF000000 and                    \ -> keep the opcode-part
        or r@ safe!                     \ or opcode and offset and ! -> ready opcode

        r> origval
        calcaddr                        \ ( new_addr ) get next addres from original value

    dup 0= until drop                   \ if 0x0 -> no further links and drop 0x0, otherwise next link
;  decimal

: RESOLVE ( lbl# -- )                   \ checks if resolve of forward branch is needed - on yes resolves
    lbl@                                \ get addr fromlbltbl
    dup 1 and if                        \ if bit<0> set -> link_address available
        1 bitclear resolve)
    else drop then ;

: HERE2LBL ( lbl# -- )                  \ here to LBLTBL
    cells lbltbl + here swap ! ;

: LB# create , does> @ dup resolve here2lbl ;
    00 lb# label0:  01 lb# label1:  02 lb# label2:  03 lb# label3:
    04 lb# label4:  05 lb# label5:  06 lb# label6:  07 lb# label7:
    08 lb# label8:  09 lb# label9:  10 lb# label10: 11 lb# label11:
    12 lb# label12: 13 lb# label13: 14 lb# label14: 15 lb# label15:

: 1STLBLLNK ( lbl# -- ) ( checked )
    here 1 or swap                      \ ( here_or_1 lbl# )
    lbl! ;                              \ here_or_1 into lbl# in lbltbl

: NXTLBLLNK ( lbl# addr -- offset_bits ) \ also address to lbltbl of next unresolved branch
    here - 6 lshift 8 rshift            \ ( lbl# offset ) offset to earlier unresolved branch
    swap                                \ ( offset lbl# )
    here 1 or swap lbl! ;               \ ( offset )

: LBLADDR ( lbl# -- addr/0x0 )
    dup lbl@ dup 0= if                  \ ( lbl# addr )
        drop 1stlbllnk 0
    else                                \ ( lbl# addr )
        dup 1 and if                    \ check bit<0> if set ( lbl# addr )
            1 bitclear                  \ -> correct address
            nxtlbllnk                   \ handle creation of link to earlier unresolved branch
        else nip                        \ drop lbl#
            here boffset
    then then ;

: (LB# create , does> @ lbladdr ;
hex 00 (lb# >lb0,   01 (lb# >lb1,   02 (lb# >lb2,   03 (lb# >lb3,
    04 (lb# >lb4,   05 (lb# >lb5,   06 (lb# >lb6,   07 (lb# >lb7,
    08 (lb# >lb8,   09 (lb# >lb9,   10 (lb# >lb10,  11 (lb# >lb11,
    12 (lb# >lb12,  13 (lb# >lb13,  14 (lb# >lb14,  15 (lb# >lb15,
decimal

: (BRH create 24 lshift , does> @ or eofopc ;
hex 0A (brh beq,    1A (brh bne,    2A (brh bcs,    3A (brh bcc,
    4A (brh bmi,    5A (brh bpl,    6A (brh bvs,    7A (brh bvc,
    8A (brh bhi,    9A (brh bls,    AA (brh bge,    BA (brh blt,
    CA (brh bgt,    DA (brh ble,    EA (brh b,      EA (brh bal,
    2A (brh bhs,    3A (brh blo,        \ << synonyms of bcs, and bcc,

    0B (brh bleq,   1B (brh blne,   2B (brh blcs,   3B (brh blcc,
    4B (brh blmi,   5B (brh blpl,   6B (brh blvs,   7B (brh blvc,
    8B (brh blhi,   9B (brh blls,   AB (brh blge,   BB (brh bllt,
    CB (brh blgt,   DB (brh blle,   EB (brh bl,     EB (brh blal,
    2B (brh blhs,   3B (brh bllo,       \ << synonyms of blcs, and blcc,
decimal



\ -- Multiplies -----
: PUT3MULREGS ( r r r opc -- opc ) \ for MULT -> no operand 2
    8 bitfld 0 bitfld 16 bitfld ;
: PUT4REGS ( r r r r opc -- opc ) \ for MLAT -> no operand 2
    12 bitfld put3mulregs ;
: PUT4REGSD ( r r r r opc -- opc ) \ for MLLT -> no operand 2
    put3mulregs 12 bitfld ;


: (MULT ( n -- ) create , does> @ putcond put3mulregs eofopc ;
: (MLAT ( n -- ) create , does> @ putcond put4regs eofopc ;
: (MLLT ( n -- ) create , does> @ putcond put4regsd eofopc ;
hex     00000090 (mult mul,     00100090 (mult muls,    00200090 (mlat mla,
        00300090 (mlat mlas,    00800090 (mllt smull,   00900090 (mllt smulls,
        00E00090 (mllt smlal,   00F00090 (mllt smlals,  00C00090 (mlat umull,
        00D00090 (mlat umulls,  00A00090 (mllt umlal,   00B00090 (mllt umlals,

        00400090 (mllt umaal,   00600090 (mlat mls,

        01000080 (mlat smlabb,  010000C0 (mlat smlabt,  010000A0 (mlat smlatb,
        010000E0 (mlat smlatt,  07000010 (mlat smlad,   07000030 (mlat smladx,
        01400080 (mllt smlalbb, 014000C0 (mllt smlalbt, 014000A0 (mllt smlaltb,
        014000E0 (mllt smlaltt, 07400010 (mllt smlald,  07400030 (mllt smlaldx,
        01200080 (mlat smlawb,  012000C0 (mlat smlawt,  07000050 (mlat smlsd,
        07000070 (mlat smlsdx,  07500010 (mlat smmla,   07500030 (mlat smmlar,
        075000D0 (mlat smmls,   075000F0 (mlat smmlsr,  0750F010 (mult smmul,
        0750F030 (mult smmulr,  0700F010 (mult smuad,   0700F030 (mult smuadx,
        01600080 (mult smulbb,  016000C0 (mult smulbt,  016000A0 (mult smultb,
        016000E0 (mult smultt,  012000A0 (mult smulwb,  012000E0 (mult smulwt,
        0700F050 (mult smusd,   0700F070 (mult smusdx,  07400050 (mllt smlsld,
        07400070 (mllt smlsldx,

        07800010 (mlat usada8,
decimal


\ -- halfword and signed data-transfer -----
\ offset: (register without shifts for register) or 8b immediate
\ incl pre en post indexing & writeback

: splitnib ( n - n0000n )
	dup >r 4 rshift 8 lshift r> 15 and or ;
: putregshw
	offbits splitnib or			\ move immediate into hi and lo nibble
	putimmhw					\ put immbit on pos 22
	indbits or					\ bits for offset mode of the indexing
	regbit if 0 bitfld then		\ put reg in 3:0 for reg-based offset
	16 bitfld 12 bitfld ;

: FDDLB25 ( opc -- opc ) 		\ bit25 must be 0 for halfword and signed byte
	1 25 lshift invert and ;
: (LOSTHW ( n -- ) create , does> @ putcond putregshw fddlb25 eofopc ;

hex	001000B0 (losthw ldrh, 		000000B0 (losthw strh,
	001000F0 (losthw ldrsh,		\ strsh, deleted as not available in ARMv8...
	001000D0 (losthw ldrsb,
	000000D0 (losthw ldrd,		000000F0 (losthw strd,

	007000B0 (losthw ldrht,		006000B0 (losthw strht,
	007000F0 (losthw ldrsht,
	007000D0 (losthw ldrsbt,
decimal


\ -- load exclusive -----
\ -- load acquire -----
\ -- load acquire exclusive -----
\ TBD# this all must be checked as the manual is a bit unclear on an immediate!!
: put2regsla
    16 bitfld                   \ Rn
    12 bitfld ;                 \ Rt
: (LA2 create , does> @ putcond put2regsla eofopc ;
hex 01900C9F (la2 lda,      01D00C9F (la2 ldab,     01F00C9F (la2 ldah,
    01900E9F (la2 ldaex,    01D00E9F (la2 ldaexb,   01F00E9F (la2 ldaexh,
    01B00E9F (la2 ldaexd,
    01900F9F (la2 ldrex,    01B00F9F (la2 ldrexd,   01D00F9F (la2 ldrexb,
    01F00F9F (la2 ldrexh,
decimal

\ -- 1reg 8b imm opcoded -----
: put1reg8imm ( reg opc -- opc )
	immbit if
		offbits or indbits 		\ #CAVE: subtract with 0x0 is not allowed
	else
		bit23 or				\ U must be U if 8b <option> is used
	then
	or							\ this either ors the indbits or the <option>
	16 bitfld ;

: (LSXCE create , does> @ putcond put1reg8imm eofopc ;
hex	0C105E00 (lsxce ldc,	0C005E00 (lsxce stc,
decimal

\ -- store release
: put2regssr
    16 bitfld                   \ Rn
     0 bitfld ;                 \ Rt
: (SL2 create , does> @ putcond put2regssr eofopc ;
hex 0180FC90 (sl2 stl,      01C0FC90 (sl2 stlb,     01E0FC90 (sl2 stlh,
decimal


\ -- store release exclusive -----
: put3regscon
    16 bitfld                   \ Rn
    0 bitfld                    \ Rt/Rm
    12 bitfld ;                 \ Rd
: (SX3 create , does> @ putcond put3regscon eofopc ;
hex 01800E90 (sx3 stlex,    01C00E90 (sx3 stlexb,
    01E00E90 (sx3 stlexh,   01A00E90 (sx3 stlexd,

    01000050 (sx3 qadd,     01400050 (sx3 qdadd,
    01600050 (sx3 qdsub,    01200050 (sx3 qsub,

    01800F90 (sx3 strex,    01C00F90 (sx3 strexb,
    01A00F90 (sx3 strexd,   01E00F90 (sx3 strexh,
decimal



\ -- saturated arithmetic -----
: put3regsconrev
    0 bitfld                    \ Rm
    16 bitfld                   \ Rn
    12 bitfld ;                 \ Rd
: (3rreg create , does> @ putcond put3regsconrev eofopc ;
hex
    06100F10 (3rreg sadd16,     06100F30 (3rreg sasx,   06100F50 (3rreg ssax,
    06200F10 (3rreg qadd16,     06200F30 (3rreg qasx,   06200F50 (3rreg qsax,
    06300F10 (3rreg shadd16,    06300F30 (3rreg shasx,  06300F50 (3rreg shsax,
    06500F10 (3rreg uadd16,     06500F30 (3rreg uasx,   06500F50 (3rreg usax,
    06600F10 (3rreg uqadd16,    06600F30 (3rreg uqasx,  06600F50 (3rreg uqsax,
    06700F10 (3rreg uhadd16,    06700F30 (3rreg uhasx,  06700F50 (3rreg uhsax,

    06100F70 (3rreg ssub16,     06100F90 (3rreg sadd8,  06100FF0 (3rreg ssub8,
    06200F70 (3rreg qsub16,     06200F90 (3rreg qadd8,  06200FF0 (3rreg qsub8,
    06300F70 (3rreg shsub16,    06300F90 (3rreg shadd8, 06300FF0 (3rreg shsub8,
    06500F70 (3rreg usub16,     06500F90 (3rreg uadd8,  06500FF0 (3rreg usub8,
    06600F70 (3rreg uqsub16,    06600F90 (3rreg uqadd8, 06600FF0 (3rreg uqsub8,
    06700F70 (3rreg uhsub16,    06700F90 (3rreg uhadd8, 06700FF0 (3rreg uhsub8,
decimal


\ -- block transfer -----
hex 10011001 decimal constant REGMARKER
: putregsbt
	indbits or regbits or		\ offset mode & regs to be saved
	16 bitfld ;				\ base-reg address where regs are saved

: SETBIT ( n -- ) \ sets bit n in value regbit
	dup 15 > if ." register expected -> " abort then
	1 swap lshift regbits or to regbits ;

: BLREGS ( reg*x -- ) \ gets reg numbers/sets bits till regmarker is seen
	16 0 do 					\ 16 regs
		dup regmarker = if leave then
		setbit
	loop drop ;				\ drop regmarker

: r-r, ( reg1 reg2 -- ) \ reads 2 regs and setsbits in range of reg1 to reg2
	2dup > if swap then			\ wrong order -> correct - could also be abort
	2dup = if drop setbit		\ 2 equal regs -> set 1 bit only
	else
		1+ swap do i setbit loop
	then ;

: BL} ( n -- ) create , does> @ to indbits blregs ;
hex	00000000 bl} },  		00200000 bl} }!,
	00400000 bl} }^,	 	00600000 bl} }!^,
decimal

: {, regmarker 0 to regbits ; 	\ start of reg list -> marker on stack >> 0x10011001

: BLTR ( n -- ) create 20 lshift , does> @ putcond putregsbt eofopc ;
hex	99 bltr ldmed,	99 bltr ldmib,	89 bltr ldmfd,	89 bltr ldmia,
	91 bltr ldmea,	91 bltr ldmdb,	81 bltr ldmfa,	81 bltr ldmda,
	98 bltr stmfa,	98 bltr stmib,	88 bltr stmea,	88 bltr stmia,
	90 bltr stmfd,	90 bltr stmdb,	80 bltr stmed,	80 bltr stmda,
decimal



\ -- MCR MRC -----
\ regs defined above - same function as cpu-regs
: putregsmmcc \ for mcr and mrc
	 5 bitfld					\ opc2 (NOT optional in wabi) 3bit
	 0 bitfld					\ CRm 4bit
	16 bitfld					\ CRn 4bit
	12 bitfld					\ Rt 4bit
	21 bitfld					\ opc1 3bit
	 8 bitfld ;
: putregsmmccrr \ for mcrr and mrrc
	 0 bitfld					\ CRm 4bit
	16 bitfld					\ Rt2 4bit
	12 bitfld					\ Rt 4bit
	 4 bitfld					\ opc1 4bit
	 8 bitfld ;

: MMCC create , does> @ putcond putregsmmcc eofopc ;
: MMRR create , does> @ putcond putregsmmccrr eofopc ;
hex	0E000E10 MMCC mcr,	0C400E00 MMRR mcrr,
	0E100E10 MMCC mrc,	0C500E00 MMRR mrrc, decimal



\ -- MRS et al
\ mrs to read all special registers
\ msr only writes to the banked registers, not to spsr, cpsr & apsr <#TBD?

\ move special register to general register
hex
: mrs, 01000000 putcond shftbits or C bitfld eofopc ; \ Rd, banked_reg, mrs,
decimal

hex
\ move reg to banked_reg
: msr, 0120F20 putcond shftbits or 0 bitfld eofopc ; \ banked_reg, Rn, msr,

: (SRB create , does> @ to shftbits ;
\ special registers
hex 4F0000 (srb spsr,  		0F0000 (srb cpsr,		0F0000 (srb apsr, \ apsr=cpsr=0x0

\ banked registers
	000200 (srb r8_usr,		010200 (srb r9_usr,		020200 (srb r10_usr,
	030200 (srb r11_usr,	040200 (srb r12_usr,	050200 (srb sp_usr,
	060200 (srb lr_usr,		080200 (srb r8_fiq,		090200 (srb r9_fiq,
	0A0200 (srb r10_fiq,	0B0200 (srb r11_fiq,	0C0200 (srb r12_fiq,
	0D0200 (srb sp_fiq,		0E0200 (srb lr_fiq,		000300 (srb lr_irq,
	010300 (srb sp_irq,		020300 (srb lr_svc,		030300 (srb sp_svc,
	040300 (srb lr_abt,		050300 (srb sp_abt,		060300 (srb lr_und,
	070300 (srb sp_und,		0C0300 (srb lr_mon,		0D0300 (srb sp_mon,
	0E0300 (srb elr_hyp,	0F0300 (srb sp_hyp,		4E0200 (srb spsr_fiq,
	400300 (srb spsr_irq,	420300 (srb spsr_svc,	440300 (srb spsr_abt,
	460300 (srb spsr_und,	4C0300 (srb spsr_mon,	4E0300 (srb spsr_hyp,
decimal



\ -- Media Instructions -----
\ belongs to group media extensions -> (MM
: put3regsmm
	8 bitfld					\ Rm
	0 bitfld					\ Rn
	16 bitfld ; 			\ Rd

: (MM3 create , does> @ putcond put3regsmm eofopc ;
hex	0710F010 (mm3 sdiv,		0730F010 (mm3 udiv,		0780F010 (mm3 usad8,

\ for the CRC-opcodes condition must be '1110"=E
	E1400040 (mm3 crc32w,	E1400040 (mm3 crc32,	\ << synonyms
	E1200040 (mm3 crc32h,	E1000040 (mm3 crc32b,
	E1400240 (mm3 crc32cw,	E1400240 (mm3 crc32c,	\ << synonyms
	E1200240 (mm3 crc32ch,	E1000240 (mm3 crc32cb,
decimal

: bfc, [hex] 07C00010 [decimal] putcond
	swap 1- over + swap
	16 bitfld					\ msb
	7 bitfld					\ lsb
	15 0 bitfld					\ 15 -> BFC iso BFI << #CHECK
	12 bitfld eofopc ;			\ Rd

: putregsbf
\	swap 1- over + swap			\ << #BUG!!
	swap 1- swap 				\ #BUG corrected
	16 bitfld					\ width
	7 bitfld					\ lsb
	0 bitfld					\ Rn
	12 bitfld ;				\ Rd

: (BF create , does> @ putcond putregsbf eofopc ;  \ #BUG in UBFX,!!
hex 07C00010 (bf bfi,	07A00050 (bf sbfx,	07E00050 (bf ubfx, decimal

\ -- extend actions -----
: put2regsxt					\ add clear of bit<9,8>
	shftbits or					\ or in the 2 ror# bits to specify which byte
	0 bitfld					\ Rm
	12 bitfld					\ Rd
;

: put3regsxta					\ add clear of bit<9,8>
	shftbits or					\ or in the 2 ror# bits to specify which byte
	 0 bitfld					\ Rm
	16 bitfld					\ Rn
	12 bitfld					\ Rd
;

: (XT create , does> @ putcond put2regsxt eofopc ;
: (XTA create , does> @ putcond put3regsxta eofopc ;
hex 06AF0070 (xt sxtb, 		068F0070 (xt sxtb16,	06BF0070 (xt sxth,
	06EF0070 (xt uxtb,		06CF0070 (xt uxtb16,	06FF0070 (xt uxth,

	06A00070 (xta sxtab,	06800070 (xta sxtab16,	06B00070 (xta sxtah,
	06E00070 (xta uxtab,	06C00070 (xta uxtab16,	06F00070 (xta uxtah,
	06800FB0 (xta sel,

	06A00F30 (xta ssat16,	06E00F30 (xta usat16,


decimal
\ bits <9,8> must stay 0x0! if a wrong shift is given than they do not

\ -- reverse bits and bytes -----
: put2regrev
	0 bitfld					\ Rm
	12 bitfld ; 			\ Rd

: (RV create , does> @ putcond put2regrev eofopc ;
hex 06BF0F30 (rv rev,	06BF0FB0 (rv rev16,		06FF0F30 (rv rbit,
	06FF0FB0 (rv revsh, 016F0F10 (rv clz,
decimal

\ -- zero reg conditional execution -----
: (ZRC create , does> @ putcond eofopc ;
hex 0320F004 (zrc sev,		0320D005 (zrc sevl,
	0320F002 (zrc wfe,		0320F003 (zrc wfi,
	0320F001 (zrc yield,	0320F000 (zrc nop,
	0160006E (zrc eret,

\ -- zero reg opcodes -----
: (ZR create , does> @ eofopc ;
hex E320F014 (zr csdb, 		F57FF044 (zr pssbb,		F57FF01F (zr clrex,
	F1010000 (zr setend.le	F1010200 (zr setend.be
decimal

\ -- zero reg 1 option opcodes -----
: putoption						\ puts 4 bits at bit<0> and higher
	shftbits 0= if				\ no option specified -> option=SY
		15 to shftbits then		\ misuse of shiftbits
	shftbits or ;

\ -- bariers -----
: (ZR1O create , does> @ putoption eofopc ;
hex F57FF050 (zr1o dmb,		F57FF040 (zr1o dsb,		F57FF060 (zr1o isb,
decimal

: (OPB create , does> @ to shftbits ;
hex F (opb sy,		E (opb st, 		D (opb ld,		B (opb ish,		A (opb ishst,
	9 (opb ishld,	7 (opb nsh,		6 (opb nshst,	5 (opb nshld,	3 (opb osh,
	2 (opb oshst,	1 (opb oshld,
decimal

\ -- 1reg Rn -----
: (1rn create , does> @ 16 bitfld eofopc ;
hex	F8900A00 (1rn rfe,  	F8B00A00 (1rn rfe!,	  \ rfe & refia are synonyms
	F8900A00 (1rn rfeia,	F8B00A00 (1rn rfeia!,
	F8100A00 (1rn rfeda, 	F8300A00 (1rn rfeda!,
	F9100A00 (1rn rfedb,	F9300A00 (1rn rfedb!,
	F9900A00 (1rn rfeib,	F9B00A00 (1rn rfeib!,
decimal

\ -- 1reg 12b IMM opcodes -----
: setu12imm ( n -- n_ready_for_or ) \ negates n if 'neg' and sets Up-bit if 'pos' for imm12
	dup 0< if negate else bit23 or then ;
: put1reg12imm ( reg imm12b opc -- opc )
	swap setu12imm swap 0 bitfld
	16 bitfld ;
: (1r12 create , does> @ put1reg12imm eofopc ;
hex	F510F000 (1r12 pldw,	F550F000 (1r12 pld, 	F450F000 (1r12 pli,


\ --0reg 16b IMM -----
hex : bkpt, FFFF and splitnib E1200070 or eofopc ; decimal
hex : hvc,  FFFF and splitnib E1400070 or eofopc ; decimal

\ --0reg 4 IMM -----
hex : smc, 01600070 putcond swap F and or eofopc ; decimal

\ --0reg 24 IMM -----
hex : svc, 0F000000 putcond swap FFFFFF and or eofopc ; decimal


\ -- CPS, CPSID, CPSIE -----
\ for use and constrictions see ARMv8 documentation!!
: putregscps
	shftbits or					\ flags-bits <aif>
	offbits or ; 				\ mode-bits
: (cps create , does> @ putregscps eofopc ;

hex	F1000010 (cps cps, 	F10C0000 (cps cpsid,	F1080000 (cps cpsie,
decimal

: (mod create , does> @ to offbits ; 		\ misuse of offbits
hex	20000 (mod user,		20001 (mod fiq,			20002 (mod irq,
	20003 (mod supervisor,	20006 (mod monitor,		20007 (mod abort,
	2000A (mod hyp,			2000B (mod undefined,	2000F (mod system,
decimal

: (fl create , does> @ to shftbits ; 		\ misuse of shftbits
hex	100 (fl <a>,	180 (fl <ai>,	140 (fl <af>,	1C0	(fl <aif>,
	080 (fl <i>,	0C0 (fl <if>,	040 (fl <f>,
decimal

\ -- 0reg mode bit17fiddle -----
: (0rmod create , does> @ offbits or bit17 bitclear ( eofopc ) .hex ;
hex	F8CD0500 (0rmod srs,	F8ED0500 (0rmod srs!,	\ srs and srsia are synonyms
	F8CD0500 (0rmod srsia,	F8ED0500 (0rmod srsia!,
	F84D0500 (0rmod srsda,	F86D0500 (0rmod srsda!,
	F94D0500 (0rmod srsdb,	F96D0500 (0rmod srsdb!,
	F9CD0500 (0rmod srsib,	F9ED0500 (0rmod srsib!,
decimal




