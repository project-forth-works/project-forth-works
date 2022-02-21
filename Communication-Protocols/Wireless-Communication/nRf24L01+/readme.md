# nRF24L01+ 2.4GHz transceiver

The [nRF24L01+](https://www.sparkfun.com/datasheets/Components/SMD/nRF24L01Pluss_Preliminary_Product_Specification_v1_0.pdf) is a cheap 2.4GHz transceiver module with a low level
part of the communication layer already in hardware available.
Features of the nRF24L01+ are, adjustable auto retransmit, RF ACK handshake, a 1 to 32 byte payload 
with variable length (Dynamic Payload), Fifo of 3 deep, 120 selectable frequencies, 
adjustable output power, CRC, etc.   

**Bidirectional transmit & receive in action on the Egel kit**
![nRF24 bidirectional test](https://user-images.githubusercontent.com/11397265/154851672-ad18f3f9-d11a-442c-b3bd-ba4cf5b9e943.jpg)


## Software

[**USCIB SPI MSP v100.f**](https://github.com/project-forth-works/project-forth-works/blob/main/Communication-Protocols/SPI/MSP430/noForth/USCIB%20SPI%20MSP%20v100.f), SPI driver for MSP430G2553  
[**Basic 24L01dn G2553-01.f**](basic%2024L01dn%20G2553-01.f), Basic transceiver routines using the Dynamic payload option  
[**Transmit test.f**](Transmit%20test.f ), Transmit command, receive & display data  
[**Receive test.f**](Receive%20test.f), On command increase a counter and sent data back  
[**Range checker G2553 usci.f**](Range%20checker%20G2553%20usci.f), Tools to help testing the range & placement of the transceivers  
[**noForth**](noForth), a noForth implementation of the example code

## Basic nRF24L01+ commands

|    Command     |      Stack      |           Function          |  
| ---------------| --------------- | --------------------------- |  
| `SETUP24L01`   | ( -- )          | Initialise nRF24l01 |  
| `TRON`         | ( -- )          | Tracer active |
| `TROFF`        | ( -- )          | Trace inactive |
| `>RF`          | ( db rate -- )  | Set transmit strength & bitrate |  
| `>LENGTH`      | ( +n -- )       | Set size of current payload |  
| `>PAY`         | ( b +n -- )     | Store byte b at location +n of the payload |  
| `PAY>`         | ( +n -- b )     | Read byte b from location +n of the payload |  
| `RESPONSE?`    | ( -- flag )     | Wait a bit, stop & leave true when an IRQ was received |  
| `XEMIT?`       | ( c -- +n )     | Send byte c, +n are the retries (max=10) |  
| `XEMIT`        | ( c -- )        | Send byte c to addressed nRF24 |  
| `XKEY`         | ( -- c )        | Receive byte c that is addressed to me |  
| `SET-DEST`     | ( +n -- )       | Set address to nRF24 +n |  

**Bidirectional demo commands**  

|    Command    |      Stack      |           Function          |  
| --------------| --------------- | --------------------------- |  
| `TRANSMIT1`    | ( +n -- )       | Send a `T` every +n milliseconds, display answer |  
| `TEST1`        | ( -- )          | Send a `T` every 50 milliseconds, display answer |  
| `RECEIVER`     | ( -- )          | Receive command, incr. counter & send it back |  

**Range & disturbance test commands**

|    Command     |       Stack      |           Function          |  
| ---------------| ---------------- | --------------------------- |  
| `CHECK`        | ( -- )           | Check all available frequency channels |  
| `CARRIER`      | ( +n -- )        | Check only frequency channel +n |  
| `WAVE`         | ( +n pwr -- )    | Send carrier on channel +n with strength pwr |  
| `PULSE`        | ( +n pwr p -- )  | Send carrier on channel +n with strength pwr in p millisec. pulses |  

   ***
   
**Bidirectional transmit & receive test in action**  

https://user-images.githubusercontent.com/11397265/154994487-bffd043c-1e07-403d-8e72-6fbb5ada894f.mp4  

Later on a self constructing mesh network will be added.