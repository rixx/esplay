-- Code from https://www.electronicwings.com/nodemcu/mpu6050-interfacing-with-nodemcu

id  = 0 -- always 0
scl = 6 -- set pin 6 as scl
sda = 7 -- set pin 7 as sda
MPU6050SlaveAddress = 0x68

AccelScaleFactor = 16384;   -- Sensitivity scale factor respective to full scale setting provided in datasheet 
GyroScaleFactor = 131;

MPU6050_REGISTER_SMPLRT_DIV   =  0x19
MPU6050_REGISTER_USER_CTRL    =  0x6A
MPU6050_REGISTER_PWR_MGMT_1   =  0x6B
MPU6050_REGISTER_PWR_MGMT_2   =  0x6C
MPU6050_REGISTER_CONFIG       =  0x1A
MPU6050_REGISTER_GYRO_CONFIG  =  0x1B
MPU6050_REGISTER_ACCEL_CONFIG =  0x1C
MPU6050_REGISTER_FIFO_EN      =  0x23
MPU6050_REGISTER_INT_ENABLE   =  0x38
MPU6050_REGISTER_ACCEL_XOUT_H =  0x3B
MPU6050_REGISTER_SIGNAL_PATH_RESET  = 0x68

function I2C_Write(deviceAddress, regAddress, data)
    i2c.start(id)       -- send start condition
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER))-- set slave address and transmit direction
    then
        i2c.write(id, regAddress)  -- write address to slave
        i2c.write(id, data)  -- write data to slave
        i2c.stop(id)    -- send stop condition
    else
        print("I2C_Write fails")
    end
end

function I2C_Read(deviceAddress, regAddress, SizeOfDataToRead)
    response = 0;
    i2c.start(id)       -- send start condition
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER))-- set slave address and transmit direction
    then
        i2c.write(id, regAddress)  -- write address to slave
        i2c.stop(id)    -- send stop condition
        i2c.start(id)   -- send start condition
        i2c.address(id, deviceAddress, i2c.RECEIVER)-- set slave address and receive direction
        response = i2c.read(id, SizeOfDataToRead)   -- read defined length response from slave
        i2c.stop(id)    -- send stop condition
        return response
    else
        print("I2C_Read fails")
    end
    return response
end

function unsignTosigned16bit(num)   -- convert unsigned 16-bit no. to signed 16-bit no.
    if num > 32768 then 
        num = num - 65536
    end
    return num
end

function MPU6050_Init() --configure MPU6050
    tmr.delay(150000)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SMPLRT_DIV, 0x07)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_1, 0x01)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_2, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_CONFIG, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_GYRO_CONFIG, 0x00)-- set +/-250 degree/second full scale
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_ACCEL_CONFIG, 0x00)-- set +/- 2g full scale
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_FIFO_EN, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_INT_ENABLE, 0x01)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SIGNAL_PATH_RESET, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_USER_CTRL, 0x00)
end

i2c.setup(id, sda, scl, i2c.SLOW)   -- initialize i2c
MPU6050_Init()
while true do   --read and print accelero, gyro and temperature value
    data = I2C_Read(MPU6050SlaveAddress, MPU6050_REGISTER_ACCEL_XOUT_H, 14)
    
    AccelX = unsignTosigned16bit((bit.bor(bit.lshift(string.byte(data, 1), 8), string.byte(data, 2))))
    AccelY = unsignTosigned16bit((bit.bor(bit.lshift(string.byte(data, 3), 8), string.byte(data, 4))))
    AccelZ = unsignTosigned16bit((bit.bor(bit.lshift(string.byte(data, 5), 8), string.byte(data, 6))))
    Temperature = unsignTosigned16bit(bit.bor(bit.lshift(string.byte(data,7), 8), string.byte(data,8)))
    GyroX = unsignTosigned16bit((bit.bor(bit.lshift(string.byte(data, 9), 8), string.byte(data, 10))))
    GyroY = unsignTosigned16bit((bit.bor(bit.lshift(string.byte(data, 11), 8), string.byte(data, 12))))
    GyroZ = unsignTosigned16bit((bit.bor(bit.lshift(string.byte(data, 13), 8), string.byte(data, 14))))

    AccelX = AccelX/AccelScaleFactor   -- divide each with their sensitivity scale factor
    AccelY = AccelY/AccelScaleFactor
    AccelZ = AccelZ/AccelScaleFactor
    Temperature = Temperature/340+36.53-- temperature formula
    GyroX = GyroX/GyroScaleFactor
    GyroY = GyroY/GyroScaleFactor
    GyroZ = GyroZ/GyroScaleFactor
    
    print(string.format("Ax:%.3g Ay:%.3g Az:%.3g T:%.3g Gx:%.3g Gy:%.3g Gz:%.3g",
                        AccelX, AccelY, AccelZ, Temperature, GyroX, GyroY, GyroZ))
    --ledbuffer:fill(math.abs(GyroY) / 3, math.abs(GyroY) / 3, math.abs(GyroZ) / 3)
    ledbuffer:fill(math.abs(AccelX) * 100, math.abs(AccelY) * 100, math.abs(AccelZ) * 100)
    ws2812.write(ledbuffer)
    tmr.delay(100000 * 10)   -- 100ms * x timer delay
end
