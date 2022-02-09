# SPI protocol for the GD32VF103 
- [**Bitbang on port-A**](bbSPI%20v100.f)  
  Note that the highlevel generates a 300 kHz clock, the low level variant a 1 MHz clock.  
  The bitbang SPI setup has no restrictions at all. More on I/O-ports from page 101ff
  of the user manual mentioned below.
- [**Hardware SPI on port-A**](SPI0%20v100.f)  
  The upper limit of the SPI clock of the GD32 is 27 MHz, so always check your settings  
  With noForth you may add the SPI setup routine to the APP vector.  
  ***The first version  of SPI-setup did not initialise the NSS pin, thanks to Martin Bitter & Wolfgang Strauss this is corrected.*** 
  More on SPI from page 377ff of the user manual.
  
  ![Inlezen een karakter in noForth](https://user-images.githubusercontent.com/11397265/120066830-9a2a3d00-c078-11eb-8c5e-d7b48160e945.jpg)
****Read a character using SPI from a W25Q64 external Flash memory****

### Two examples

| File name | Commands | Purpose |  
| ------------------- | ------------------- | ---------------------- |
| [SPI-loopback.f](SPI-loopback.f)  | `COUNTER` | A counter as simplest loopback test |
| [Flash driver GD32.f](Flash%20driver%20GD32.f)  | `SPI-ON`| Activate SPI-interface to W25Q64 Flash memory chip| 
|                        | `FILL1 0 write-sector` | Fill buffer with pattern en write to Flash sector 0 |  
|                        | `0 100 FDUMP` |  Dump sector 0 showing the written contents, etc. |
| [SPI OLED display GD32.f](SPI%20OLED%20display%20GD32.f) | `DEMO` | Initialise OLED & display P-F-W until a key is hit |
|                        | `&PAGE` | Erases the OLED and sets the cursor in upper left corner |

```

```
![afbeelding](https://user-images.githubusercontent.com/11397265/120901097-fffa6400-c638-11eb-9777-d6ff3f77e155.png)  
**NOF filesystem on SPI Flash initialised while booting the GD32VF103**  

  
  
### More information on the GD32VF103
- [GD32VF103_Datasheet_Rev_1.3.pdf](http://gd32mcu.com/download/down/document_id/221/path_type/1)
- [GD32VF103_User_Manual_EN_V1.2.pdf](http://gd32mcu.com/download/down/document_id/222/path_type/1)

