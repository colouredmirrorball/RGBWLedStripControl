# RGBWLedStripControl

This is a way to control SK6812 RGBW LED strips using a distributed network of Arduinos and Raspberry Pis running Processing. The Processing-Master sketch runs on the main laptop, communicating over network with the Processing-Local sketches. These Processing-Local sketches can communicating serially with the Arduinos driving the LED strips.

This is detailed in my blog post, including a description of the required hardware: https://text2laser.be/blog/2018/11/11/led-strip-control-using-arduinos-raspberry-pis/

## Installing

 * Download and run Processing from https://processing.org on both the main control device (a laptop), and on all the remote devices that connect via USB to an Arduino. I used Raspberry Pis for the remote devices, but any device that can run a JVM, connect to network and communicate serially with Arduino works. You can also use a laptop as both the master controller and remote device, running the two sketches at the same time.
  * Download the Arduino IDE from https://www.arduino.cc/en/Main/Software
  * Open the Arduino IDE and load in "WebsiteRGBWSerialCommExample.ino". Upload this firmware to all the Arduino controllers.
  * Connect the data pin of the RGBW strip to pin 7 on the Arduino and connect the ground of both the strip and the Arduino to the ground of the PSU. Do not connect power from an external PSU to the 5V of the Arduino. Do not power more than 50 LEDs from the Arduino.
  * Connect all Arduino/LED strip combos to the remote devices via USB.
  * Open Processing on the master control device and open "WebsiteRGBWProcessingMasterExample.pde". Hit ctrl+r to run it.
  * Open Processing on the remote device and open "WebsiteRGBWProcessingLocalExample.pde". Hit ctrl+r to run it.
  * Find the IP address of all the remote devices and fill it in in the master control sketch (click the left "+" button for every strip)
  
  How to use is described in the blog post linked above.
  
  ## Adapting for WS2812
  
  The easiest way to adapt this framework to regular WS2812 RGB strips is to comment out line 149 in the Arduino sketch: https://github.com/colouredmirrorball/RGBWLedStripControl/blob/master/Arduino/WebsiteRGBWSerialCommExample/WebsiteRGBWSerialCommExample.ino#L149
  This will make the sketch only send RGB values, even though it receives RGBW.
