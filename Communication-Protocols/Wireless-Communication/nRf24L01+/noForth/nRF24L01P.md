# nRF24L01+

The nRF24L01+ is a cheap 2.4GHz transceiver module with a low level
part of the communication layer already in hardware available.
Features of the nRF24L01+ are, auto retransmit, RF ACK handshake,
32 byte payload, Fifo of 3 deep, 120 selectable frequencies, 
adjustable output power, CRC, etc.


## Software

[**USCIB SPI MSP v100.f**](Link), SPI driver for MSP430G2553  
[**basic 24L01dn G2553 example.f**](Link), Basic transceiver routines  
[**Transmit test.f**](Link), Transmit command, receive & display data  
[**Receive test.f**](Link), On command increase a counter and sent data back  
[**Range checker G2553 usci.f**](Link), Tools to help testing the range & placement of the transceivers  


## Basic nRF24L01+ commands

|    Command     |      Stack      |           Function          |  
| ---------------| --------------- | --------------------------- |  
| `SETUP24L01`   | ( -- )          | Initialise nRF24l01 |  
| `TRON`         | ( -- )          | Tracer active |
| `TROFF`        | ( -- )          | Trace inactive |
| `>RF`          | ( db rate -- )  | Set transmit strength & bitrate |  
| `>LENGTH`      | ( +n -- )       | Set size of current payload |  
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

Later on a self constructing mesh network will be added.
