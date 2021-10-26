# noForth versions of the SPI protocol

- Bitbang
- USCI
- eUSCI

![SPI OLED test](https://user-images.githubusercontent.com/11397265/120072220-fbf7a080-c092-11eb-9faf-abe96bc6d1c5.jpg)
****SPI used to drive an OLED display & W25Q16 external Flash memory****

### More information on the MSP430G2553

- [MSP430x2xx Family guide SLAU144J.PDF](https://www.ti.com/lit/ug/slau144j/slau144j.pdf), SPI on page 444ff  
- [MSP430G2553 datasheet SLAS735J.PDF](https://www.ti.com/lit/ds/symlink/msp430g2553.pdf), port data on page 49ff  

```
```

### Examples

| File name | Commands | Purpose |  
| ------------------- | ------------------- | ---------------------- |
| [SPI-loopback MSP430.f](SPI-loopback%20msp430.F)  | `COUNTER` | A counter as simplest loopback test |
| [SPI OLED display.f](SPI%20OLED%20display.f)     | `DEMO`    | Show text on a graphic OLED display |
| [Flash driver MSP430.f](Flash%20driver%20MSP430.f)    | `4 SPI-SETUP`| Activate SPI-interface to Flash memory chip| 
|                        | `FILL1 0 write-sector` | Fill buffer with pattern en write to Flash sector 0 |  
|                        | `0. 100 FDUMP` |  Dump sector 0 showing the written contents, etc. |
| [WS2812 simple G2553.f](WS2812%20simple%20G2553.f)    | `SHOW` for MSP430G2553  | Display five different colors on max. 40 WS2812 leds |
| [WS2812 simple FR5949.f](WS2812%20simple%20FR5949.f)   | `SHOW` for MSP430FR59xx | the number of LEDs maybe changed by editing `#LEDS` |

```
```
![OLED text driver](https://user-images.githubusercontent.com/11397265/127749756-870cfe0c-ceed-4b74-9379-a400e31282f2.jpg)
