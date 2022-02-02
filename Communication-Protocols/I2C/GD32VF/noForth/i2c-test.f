\ Show if a device with address 'dev' is present on the I2C-bus
: I2C?          ( dev -- )
    i2c-on  device!  {device-ok?}
    0= if  ." Not "  then  ." Present " ;

\ End ;;;
