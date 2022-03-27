# Mesh network
![mesh in action](https://user-images.githubusercontent.com/11397265/157903902-66324963-a68f-43bf-bdf6-fc22b96b761f.jpg)

## The idea

Using standard wireless transceivers to form a self constructing mesh network.
Basically each node has the same structure, the only difference is the node address.
The transceiver used here is the nRf24L01 or the Chinese clone named 
[SI24R1](https://datasheet.lcsc.com/lcsc/2202241830_Nanjing-Zhongke-Microelectronics-Si24R1_C14436.pdf).


## Built on top

The basis for this example are these files: [SPI](../../SPI/), 
[Basic 24L01dn](../nRf24L01+/basic%2024L01dn%20G2553-01a.f) file
and the [bit array](https://github.com/project-forth-works/project-forth-works/tree/main/Data-Structures/Bit-Array), 
these are used for the driver of the network layer.
This driver uses **dynamic payload** to optimise the troughput of the network.

- [Generic forth](Generic-version), version of the mesh network  
- [MSP430G2553 & MSP430F149](G2553-&-F149), noForth mesh network version  
- [GD32VF103](GD32VF103), noForth mesh network version  
- [MSP430FR5949](FR59xx), noForth mesh network version  

## Flexible RF settings

The most important RF setting are build into the word `SETRF` this word sets
the following parameters:

* RF-channel number; 0 to 125
* Scan transmit power; -18db to 0db
* Transmit power during normal use; -18db to 0db
* Communication bitrate; 250 Kbit, 1 Mbit or 2 Mbit
* Unique node address; 0 to max. node number (15 in this example)


## Payload structure

The **Dynamic payload** format is 1 to 32 bytes. For this implementation
the minimum payload size is 2 bytes (the command and destination). 
This is because the node handler does a check on the destination before accepting
a command. The complete payload is described in the table below.

|   0   |  1  |  2  |    3   |  4  |  5 to 31   |  
| :-------: | :-----: | :-----: | :--------: | :-----: | :-----------: |  
| Command | Dest. | Orig. | Sub node | Admin | d00  to d1A |  

```
 0 pay>  = Command for destination      1 pay>       = Destination node
 2 pay>  = Origin node                  3 pay>       = Address of sub node
 4 pay>  = Administration byte          5 to 31 pay> = Data 0x1A (#26) bytes
```

## Time out on network commands

Because network commands can get lost, an important feature is a time-out on the command response. 
This time-out must be constructed with a built-in timer or by using a built-in cycle counter 
if present on the microcontroller used.  
This is code example is for the GD32VF103 Risc-V microcontroller:
```fort
hex
code TICK   ( -- u )    \ Read half (low 32-bits) of 64-bit rdcycle counter
    sp -) tos .mov
    tos B00 zero csrrs  \ Read low counter
    next
end-code

decimal
: MS        ( ms -- )        
    104000 *            \ Convert MS to CPU ticks
    tick >r             \ Save tick counter
    begin
        tick r@ -       \ Calc. ticks passed
    over u< 0= until    \ Larger or equal to given ticks?
    r> 2drop ;          \ Yes ready
```

This structure is used in the word `<WAIT>` this word catches the response
from the addressed node but only within the given time period.


## Node command interpreter

Here is a complete list of the comans of the node command interpreter.
It is also known as the handler within this code example.

|   Token    | Function          |  
| :--------: | ----------------- |  
| F          | Execute Forth command string |  
| \|         | Stop free running program |  
| |  |  
| *          | Power output on |  
| _          | Power output off |  
| | |  
| I          | Give node info |  
| H          | Give node connection info |  
| P          | Respond on a ping |  
| N          | Give free node number |  
| | |  
| s          | Scan and note any node within reach |  
| i          | Gather node type info from other nodes |  
| h          | Gather network connection data |  
| | |  
| ^          | Receive hop data from other node |
| @          | Receive type info from node |  
| R          | Register a new node to the network |  
| }          | Answer when an external command is finished |  
| #          | Receive free node number from network |  


## Interactive node

The node command interpreter is integrated in a the word `NODE`. 
A sample implementation is shown here. The word `GET?` is a primitive
outer interpreter as is commonly used in many Forth systems.
It reads and stores characters when a key was hit. 
With the escape key we are leaving this node interpreter loop.
A backspace removes typos, after the enter key the string
is evaluated, an error leaves this loop too.

#### Example code
```forth
hex  0 value LEN  create BUF 20 allot
: GET?      ( -- 0|1B )
    0  key? if                              \ Key pressed?
        key dup 1B = if  or  exit  then     \ Yes, exit on escape char!
        dup 0D = if                         \ Is it ENTER?
            drop  space  buf len evaluate   \ Yes, interpret string
            0 to len  cr                    \ New line
            t? 0= if  ." N>"  then          \ Display prompt when tracer is off
        else
            dup 8 = if                      \ Is it backspace?
                emit bl emit 8 emit  -1     \ Yes, remove char
            else
                dup emit  buf len + c!  1   \ Normal char, show & save
            then
            +to len                         \ Adjust length
        then
    then ;

: NODE     ( -- )
    startnode  ( tron )  troff  0 to len
    begin  begin  handler? until  get? until ;
```

This program is originally written in noForth. 
In noForth the serial input and output is vectored.
Replacing the key vector does the same as the `NODE`program.

```forth
: XKEY)     ( -- c )    begin  handler? until  key) ;
```
The last line in the word `STARTNODE` contains this line, 
so after startnode is executed the interactive node is ready.
```forth
['] xkey)  to 'key  \ Add KEY & node handler to KEY
```


## NODE command set

If you want to try out this mesh network implementation, these are the 
words to play with. Note that each node also contains a primitive
event handler. This handler uses a pin as input for a switch to ground. 
This switch alternately activates the words `ALL-ON` or `ALL-OFF`.  

| Word      |   Stack   | Description |  
| ----      | --------- | ----------- |  
| `.STATUS` | ( -- )    | Show most important RF data |  
| `.ALL`    | ( -- )    | Show network connection data |  
| `REGISTER` | ( -- )   | Connect myself to an existing network |  
| `ON`      | ( +n -- ) | Activate power ouput on node +n |  
| `OFF`     | ( +n -- ) | Deactivate power ouput on node +n |  
| `ALL-ON`  | ( -- )    | Activate all ouputs on the network |  
| `ALL-OFF` | ( -- )    | Deactivate all ouputs on the network |  
| `STOP`    | ( +n -- ) | Halt any free running program on node +n |  
| `>F`      | ( +n ccc -- ) | Execute the forth word ccc on node +n |   
| `SCANX`   | ( -- )    | Scan & note direct accessible nodes |  

   ***

![scanx](https://user-images.githubusercontent.com/11397265/157905223-70621a30-4d84-4d40-b706-f30acef52bed.jpg)  
**SCANX result**


## Network tools

The mesh network code adds some additional words for constructing
new functions above the basic node command interpreter. These are:

|   Word    |      Stack       |       Function        |  
| --------- | ---------------- | --------------------- |  
| `ALL`     | ( -- a )      | Address of a BIT-table with all found nodes |  
| `DIRECT`  | ( -- a )      | Address of a BIT-table with direct accessable nodes |  
| `INDIRECT`| ( -- a )      | Address of a BIT-table with indirect accessable nodes |  
| `#MAP`    | ( -- +n )     | Leave the size of a bitmap |  
| `GET*`    | ( +n a -- 0\|b ) | Check if node +n present in bit-array a? |  
| `*CLR`    | ( +n a -- )   | Remove node +n from bit-array a |  
| `*COUNT`  | ( a -- +n )   | Leave number of nodes found in bitmap a |  
| `>USER`   | ( a -- )      | Copy nodes to node accu for app programmer |  
| `>WORK`   | ( a -- )      | Copy nodes to node accu for internal functions |  
| `NEXT?`   | ( a -- 0\|+n -1 ) | Leave node number of the first used node in bitmap a & erase the bit |  
| `RUN`     | ( -- )        | Allow a program to run free |  
| `HALT?`   | ( -- f )      | Alternative KEY? to stop node programs |  
| `<WAIT>`  | ( +n -- )     | Wait +n milliseconds & respond to external network commands, leave after an } was received |  
| `>OTHERS` | ( c -- )      | Send node command c to all nodes noted in WORK with a timeout of 128 ms |  
| `FINISH`  | ( -- )        | End network buildup with adding node type information |  

#### Generic forth example code
```forth
hex
: RUN-FORW  ( -- )      \ Running light on all outputs in my network
    run  begin
        all >user
        begin  user next? while
        dup on  100 <wait>
        off  30 <wait>  repeat
    halt? until ;
```
   ***
   
- [BUILD](Generic-version/Tools/Build%20(3.9d).f), constructs a (hopping) mesh network  
- [PING](Generic-version/Tools/Ping-2.f), check node connection/availability  
- [DEMO's](Generic-version/Tools/Mesh-demos.f), that activate the node outputs in different ways  
- [Simple demo](Generic-version/Tools/automesh.f), Primitive network build routine & running light demo

   ***
   
**All steps taken by the `BUILD` routine**  
![Build done color](https://user-images.githubusercontent.com/11397265/157910410-addf6e4d-2e14-478c-8426-47e8435576b7.jpg)

