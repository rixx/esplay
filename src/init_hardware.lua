print("Initializing LEDs")
ws2812.init(ws2812.MODE_SINGLE)
ledbuffer = ws2812.newBuffer(1, 3);  -- 1 is the amount of LEDs, 3 is the amount of channels
print ("Hardware init done.\r\n")
