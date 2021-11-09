\ primitive circular buffer SwiftForth                             uh 2021-08-05

\ see https://github.com/Project-Forth-Works/data-structures/primitive-circular-buffer for details 

\ Internal words
package primitive-circular-buffer-package

\ 1. define the fields of the primitive circular buffer { k idx x0 ... xk-1 }
0
      : _idx ( -- ) @ ;                  \ index to next free entry
cell+ : _x0 ( addr1 -- addr2 ) @ cell+ ; \ address of first entry
1 cells +Field _k                        \ number of entries in primitive circular buffer
drop

\ 2. access entries in primitive circular buffer pcb
: _x[] ( i pcb -- 'x[i]) \ get address of ith entry in primitive circular buffer pcb
    _x0  swap cells + ;

: _x[idx]  ( pcb -- 'x[idx] ) \ get address of next free entry in primitive circular pcb
    dup  _idx @  swap _x[] ;

\ 3. manage circular buffer index
: advance ( k i -- i' ) \ increment index i wrapping around with k entries
   1+ swap mod ;

: advance-idx ( pcb -- ) \ increment index of primitive circular buffer pcb
   dup _k @  swap _idx dup >r  @ advance r> ! ;  


\ 4. Interface words
public

: pcb-init ( pcb -- )  \ initialize primitive circular buffer
   0 swap _idx ! ;

: pcb! ( x pcb -- addr )  \ store value x in next free entry of primitive circular buffer cb
   swap over _x[idx] !  advance-idx ;

: pcb@0 ( pcb -- x ) \ retrieve the oldest entry from primitive circular buffer cb
   _x[idx] @ ;

: pcb@ ( i pcb -- x ) \ retrieve the ith oldest entry from primitive circular buffer cb
   dup >r _idx @ +  r@ _k @ mod  r> _x[] @ ;

private

: allocate-primitive-circular-buffer ( k -- addr ) \ allocate a primitive circular buffer leaving its address
   here swap cells cell+ ( for idx ) allot ; \ RAM: ( idx x0 ... x_k-1 )

: setup-primitive-circular-buffer ( k addr -- )
   , ( 'ram ) , ( k ) ; \ ROM: { 'ram k }


public 

: new-primitive-circular-buffer ( k -- addr )
   dup allocate-primitive-circular-buffer \ RAM
   setup-primitive-circular-buffer ;      \ ROM

: Primitive-Circular-Buffer ( k <name> -- )
   dup allocate-primitive-circular-buffer \ RAM
   Create
   setup-primitive-circular-buffer ; \ ROM

end-package

\ 5. integrated test

Marker ***tests***

include %SwiftForth/unsupported/anstest/tester.f

5 Primitive-Circular-Buffer pcb  pcb pcb-init

{> 10 pcb pcb! 20 pcb pcb! 30 pcb pcb! 
   40 pcb pcb! 50 pcb pcb! 60 pcb pcb!
    0 pcb pcb@ 70 pcb pcb!  0 pcb pcb@  0 pcb pcb!  0 pcb pcb@  0 pcb pcb! 
    0 pcb pcb@  0 pcb pcb!  0 pcb pcb@  0 pcb pcb!  0 pcb pcb@  0 pcb pcb!
    -> 20 30 40 50 60 70 }

***tests***

