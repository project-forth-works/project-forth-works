# SPI examples

Here you will find examples for SPI usage with mecrisp-quintus running on the **Longan Nano** Board by Sipeed and maybe other boards too. This board has the GD32VF103xxx MCU 48-Pinout. If you want to use it on other flavors (36, 64, or 100 pins) you'r on your own.

There are some naming conventions

```
SPI         protocol
0, 1, 2     Number of used hardware module if any
soft        Software version (bitbanging)
hard        Version using the built in module of the GD32VF103
dma         Version using the built in module with DMA feature of the GD32VF103
```

All examples would define their own word sets p.e. **{spi1** . To use them within the example files (BME280.fs) these names has to be converted to the common names p.e. **{SPI**. This is done be the files called spix-normalize.fs.
The BME280.fs example relies on the existence of the words: **{SPI SPI} SPI-IN SPI-OUT SPI-I/O**.

At the moment there are two examples: 

- **[BME280.fs**](BME280/readme.md), It is the testcase for the SPI code. It uses the **BME280** sensor chip.  
With this example one can proof the function of the SPI connection. It resets the **BME280** and reads out the chip ID and some calibration data. One is able to read the raw data of temperature, air humidity and air pressure. To get the real values one has to do some calculations using the calibration data and the formulas published in the datasheet.  

Also in every SPI code suitable for the **BME280** you will find a short hint how to wire the **BME280** to the GD32VF103 in this special case to the Longan Nano.

**[sd-card.fs**](sd-card-bitbang/sdcard.fs), This shows how to access a sd-card plugged in into the **Longan Nano** board. It uses a software SPI.  


### Files
| Filename | Comment |
| -------------------------- | ------------------------------------------------------------------------------------------- |
| readme.md | This file |
| spi-soft.fs             | Your totally free to choose the pins you use. It will consume MCU time.  | 
| spi0-hard.txt           | Will use the built in module of the GD32VF103. Here is shown how to remap the pins used by SPI0. That makes it possible to have the display of the Longan Nano running in parallel.  |
| spi0-normalize.fs | Translates the words **{SPI0 SPI0} SPI0-IN SPI0-OUT SPI0-I/O** to **{SPI SPI} SPI-IN SPI-OUT SPI-I/O**       
| spi1-hard.fs     | Will use the built in module of the GD32VF103. Can act as a template for all spiX interfaces. It releases the MCU.  It is shown how to switch to a software CS line. For that follow the steps shown in spi1-set-software-cs.fs.  |           
| spi1-normalize.fs | Translates the words **{SPI1 SPI1} SPI1-IN SPI1-OUT SPI1-I/O** to **{SPI SPI} SPI-IN SPI-OUT SPI-I/O**
| spi1-set-software-cs.fs | This shows how to use the built in module and controll the **CS** line by yoursekft - not by the module. |
| spi2-hard.fs| Will use the built in module of the GD32VF103. It is here to show how to release the JTAG pins so that they could be used by interface SPI2.  |
| spi2-normalize.fs | Translates the words **{SPI2 SPI2} SPI-IN2 SPI-OUT2 SPI-I/O2** to **{SPI SPI} SPI-IN SPI-OUT SPI-I/O**


### Directories 
| Directory | Comment |
| ------------------ | ---
| BME280 | You're totally free to choose the pins you use. Takes in count a specialty (clock) of the protocol the **BME280** needs.  |
| sd-card-bitbang | Software example how to get access to a sd-card  |

# More info about the GD32VF103

https://dl.sipeed.com/shareURL/LONGAN/Nano/DOC

here you'll find among others:

Bumblebee core intro_en.pdf  
Bumblebee core datasheet_en.pdf  
GD32VF103_Datasheet_Rev 1.1.pdf  
GD32VF103_User_Manual_EN_V1.2.pdf  



mb
