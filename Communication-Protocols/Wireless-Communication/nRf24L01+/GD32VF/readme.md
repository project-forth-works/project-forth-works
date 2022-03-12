# GD32VF103 implementation for nRF24L01+

The [nRF24L01+](https://www.sparkfun.com/datasheets/Components/SMD/nRF24L01Pluss_Preliminary_Product_Specification_v1_0.pdf) is a cheap 2.4GHz transceiver module with a low level
part of the communication layer already in hardware available.
Features of the nRF24L01+ are, adjustable auto retransmit, RF ACK handshake, a 1 to 32 byte payload 
with variable length (Dynamic Payload), Fifo of 3 deep, 120 selectable frequencies, 
adjustable output power, CRC, etc.   

**Bidirectional transmit & receive in action between the Egel kit & GD32VF103 SEEED board**
![MSP430   GD32VF exchanging data](https://user-images.githubusercontent.com/11397265/155599863-9fa5ca15-f055-4ea3-b152-34250a257ad4.jpg)


## Software

- [**noForth**](noForth), implementation of a nRf24L01+ driver  
Etc.  
