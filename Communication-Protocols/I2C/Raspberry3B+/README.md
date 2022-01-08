# I2C driver for Raspberry 3b+.

This is the start of a I2C driver for a bare-metal Raspberry 3b+. The first part are the words to control the I2C controller (BSC1) of the Raspberry.

The second part is an implementation of an I2C-scan. It scans the I2C bus and gives a pretty overview of available devices like this:


	      0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0xA 0xB 0xC 0xD 0xE 0xF
      0x0 g/s cba res res hsm hsm hsm hsm --- --- --- --- --- --- --- ---
      0x1 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
      0x2 --- --- --- --- --- --- --- x27 --- --- --- --- --- --- --- ---
      0x3 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
      0x4 --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
      0x5 x50 x51 x52 x53 x54 x55 --- --- --- --- --- --- --- --- --- ---
      0x6 x60 --- --- --- --- --- --- --- --- --- --- --- --- --- --- x6F
      0x7 --- --- --- --- --- --- --- --- 10b 10b 10b 10b fut fut fut fut
      
In this example you can see 6 Eeproms ( 0x50-0x55 ), a LCD, a RTC and a compass-module. Please note that there is no more specific way of further identification in the I2C system.    
      
It is also good to note that on the Raspberry 3B+ only BSC1 (Bascom Serial Controller 1) is available to the user. Both BSC0 and BSC2 are used by the Raspberry for internal purposes. To be more specific: for the communication with HDMI and the camera controller and to identify eventual boards plugged in into the Raspberry.
Trying to use these two controllers will result in a failure without any error-messages or warnings.


Words assumed to be available: SETFUNCGPIO ( an internal word which sets the ALT function of a GPIO )




