# BME280 

 
<img align="left" src="https://user-images.githubusercontent.com/64471355/128324729-9aef0436-ee0f-4c95-b3f0-04b9e3c55c77.jpg"> I use this little breakout board. Be aware that it comes with seven pads. There are others with 5 or 6 pads. The sensor itself is the tiny silver square with a very tiny hole in the middle of the upper half of the board.  
The BME280 is a sensor that measures air humidity, air pressure and temperature. It can be configured to measure in variant speeds and resolutions. The higher the speed the lower the resolution.  
The example code shown in BME280.fs was made for an application drawing a carnot diagram of a stirling engine, so it had to be fast. The data was send to a PC where the time consuming calculations were made. If you use it you are able to read out the ID code of the BME280 to test the connection it should be #96 or $60. You will have the calibration data and the ability to read out raw data (pressure, temperature and humidity).   
There are other sensor ICs in the world that will show the real values for temperature and pressure without extra calculations but they are somewhat more expensive.

## Workflow
- Load the spixxx.fs code that fits your constraints.
- Connect following the wiring in the spixxx.fs code. 
- Load spixxx.normalization file if any. 
- Load BME280.fs  


[Datasheet of the BME280](https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bme280-ds002.pdf)

mb
