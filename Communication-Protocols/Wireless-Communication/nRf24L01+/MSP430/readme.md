# MSP430 implementation for nRF24L01+

The [nRF24L01+](https://www.sparkfun.com/datasheets/Components/SMD/nRF24L01Pluss_Preliminary_Product_Specification_v1_0.pdf) is a cheap 2.4GHz transceiver module with a low level
part of the communication layer already in hardware available.
Features of the nRF24L01+ are, adjustable auto retransmit, RF ACK handshake, a 1 to 32 byte payload 
with variable length (Dynamic Payload), Fifo of 3 deep, 120 selectable frequencies, 
adjustable output power, CRC, etc.   

**Bidirectional transmit & receive in action on the Egel kit**
![nRF24 bidirectional test](https://user-images.githubusercontent.com/11397265/154851672-ad18f3f9-d11a-442c-b3bd-ba4cf5b9e943.jpg)


## Software

[**MSP430 noForth**](MSP430/noForth), a noForth implementation of the example code  
Etc.  
