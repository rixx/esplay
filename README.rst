ESPlay
======

ESPlay contains the software for games running on one or multiple ESP
controllers connected to a WS2812 RGB LED, a gyroscope+accelerometer board, a
button and a vibro motor.

Getting Started
---------------

Hardware
~~~~~~~~

TODO: List hardware

Software
~~~~~~~~

The firmware is located in the firmware directory. It's standard NodeMCU
firmware.  It was built against the 1.5.4.1-final branch and includes the
following modules: bit, file, gpio, http, i2c, net, +node, pwm, tmr, uart,
wifi, ws2812.

Flash it using the tool of your choice, e.g. ``esptool``::

    esptool --port /dev/ttyUSB1 write_flash 0x0000 ./firmware/0x0000.bin


History
-------

This project was inspired by the PlayStation Move game `Johann Sebastian
Joust`_, which was ported to several_ open_ source_ projects.


.. _Johann Sebastian Joust: http://jsjoust.com/
.. _several: https://github.com/adangert/JoustMania
.. _open: https://github.com/Juerd/opentilt
.. _source: https://github.com/Ghoust-game/ghoust
