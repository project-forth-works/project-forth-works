# Sensors

The idea is to give examples for a variety of avialable sensors.  
To measure time, temperature, pressure, magnetism, distance, light level, etc.  

- [Measuring distances](Measuring-distance), using ultrasonic and other sensors.  
- [Reflection sensors](Reflection-sensors ), a sensor that uses (infrared) light to detect the precence of an object.  

**Some examples**

| Temperature | Light | Motion | Contact | Reflection |  
| :----: | :--------: | :---: | :------: | :----------: |  
| LM75 | APDS9300 | SB312 | Microswitch | CNY70 |  
| ![LM75 temperature sensor](https://user-images.githubusercontent.com/11397265/154798280-a0c6dd93-676c-4301-925d-88984904f4e4.jpg)  | ![ADPS9300 light sensor](https://user-images.githubusercontent.com/11397265/154798292-9c3b40ce-b7af-441e-ba1c-d94350d0d21a.jpg) | ![PIR-sensor example](https://user-images.githubusercontent.com/11397265/154798297-0391d3e3-3ed6-4926-bfb7-337668134196.jpg) | ![Mechanical touch sensor](https://user-images.githubusercontent.com/11397265/154798394-5ae9f9bf-3c89-4a43-bd54-f2d936f69e82.jpg) | ![Ushi reflection sensor-3a](https://user-images.githubusercontent.com/11397265/154798472-a9057e57-5b72-4e76-a287-f931f350666e.jpg) |

   ***

|  Sensor | Purpose |  Short description |
| -------- | ------------ | --------------------------------------------------------------- | 
| [HC-SR04](Measuring-distance) | Measure distance | Measures distance using Ultrasonic sound |
| [LM75(A)](https://github.com/project-forth-works/project-forth-works/blob/main/Communication-Protocols/I2C/Device-drivers/LM75.f) | Temperature | Measures temperature with .5° Celcius resolution |
| [TMP75](https://github.com/project-forth-works/project-forth-works/blob/main/Communication-Protocols/I2C/Device-drivers/TMP75.f) | Temperature | Measures temperature with  0.0625° Celcius resolution |
| [APDS9300](https://github.com/project-forth-works/project-forth-works/blob/main/Communication-Protocols/I2C/Device-drivers/APDS9300.f) | (IR)Light | Infrared and visual light sensor |
| [PIR](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e018) | Motion detector | Passive infrared motion detector |
| [Touch](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e019) | Touch sensors | [Mechanical switch](https://home.hccnet.nl/willem.ouwerkerk/egel-for-msp430/egel%20for%20launchpad.html#e018) or capacitive touch switch & slider |
| [BME280](https://github.com/project-forth-works/project-forth-works/blob/main/Communication-Protocols/SPI/GD32VF/mecrisp-quintus/BME280/BMP280.fs) | Pressure, temperature & humidity |  Measure pressure, temperature and humidity |
| [TCND5000](Reflection-sensors) | Reflection sensor | Detection of nearby subjects, other examples are: [IS471F](https://www.sigmaelectronica.net/manuals/IS471F.pdf) or [CNY70](https://www.vishay.com/docs/83751/cny70.pdf),  see [Ushi book](https://home.hccnet.nl/willem.ouwerkerk/download/ushiboek.pdf) | 

More info look at each individual subject.
