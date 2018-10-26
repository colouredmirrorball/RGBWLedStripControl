import processing.net.*;
import processing.serial.*;

ArrayList<LedStrip> ledStrips = new ArrayList();

Server server;



void setup()
{
  size(400, 255);
  println(Serial.list());

  surface.setLocation(20, 20);

  server = new Server(this, 8008);

  resetStrips();



  println("Local sketch booted in", millis(), "milliseconds.");
}

boolean idle = true;

float hue = 0;

void draw()
{

  if (idle)
  {
    colorMode(HSB);
    hue += 0.1;
    if (hue > 255) hue = 0;
    color c = color(hue, 255, 255, 0);
    background(c);

    colorMode(RGB);

    for (int i = 0; i < ledStrips.size(); i++)
    {
      setMessage(i, 'c', (byte) 25, c);
    }
  }

  Client c = server.available();
  try
  {
    if (c != null)
    {
      //Quit idle mode when a network message has been received
      idle = false;

      //Parse the message
      byte strip = (byte) (c.read() & 0xff);  //com port idx
      byte command = (byte) (c.read() & 0xff);
      byte value = (byte) (c.read() & 0xff);
      byte data1 = (byte) (c.read() & 0xff);
      byte data2 = (byte) (c.read() & 0xff);
      byte data3 = (byte) (c.read() & 0xff);
      byte data4 = (byte) (c.read() & 0xff);

      setMessage(strip, (char)command, value, color(data1, data2, data3, data4));

      //Reply with "S" for success
      c.write("S");

      while (c.available() > 0) c.read(); //flush
    }
  }
  catch(Exception e)
  {
    println("An error happened while trying to parse network message!");
    e.printStackTrace();

    //If possible, reply with "F" for failure
    if (c != null) c.write("F");
  }
}


//Rescan for connected Arduinos
void resetStrips()
{
  //Get rid of all current communication
  for (LedStrip strip : ledStrips)
  {
    strip.listener.dispose();
  }

  //Get rid of the ones we already have
  ledStrips.clear();

  //Find all connected devices
  for (String s : Serial.list())
  {
    //On Windows, all connected devices should be Arduinos
    //On Raspi, only add the ones that have USB in their name
    if (System.getProperty("os.name").startsWith("Windows") || s.contains("USB"))
    {
      LedStrip newStrip = new LedStrip(this, s, 115200);
      ledStrips.add(newStrip);
      println("Added serial port", s);
    }
  }
}

//Set up the next scheduled message for the LED strip
void setMessage(int strip, char command, byte value, color c)
{
  //Somebody has not been paying attention
  if (strip >= ledStrips.size())
  {
    println("Error: invalid strip number! Connected strips:", ledStrips.size(), "Addressed strip:", strip);
    return;
  }

  //Create a new message (the bit shuffling is a faster way to extract colour data)
  //the alpha channel of the color is used as the value for white
  StripMessage message = new StripMessage(command, value, (byte) ((c >> 16) & 0xff), (byte) ((c >> 8) & 0xff), (byte) ((c ) & 0xff), (byte) ((c >> 24) & 0xff));


  try
  {
    ledStrips.get(strip).setMessage(message);
  }
  catch(Exception e)
  {
    println("Error happened when trying to set message:", e);
    e.printStackTrace();
  }
}

//Class containing all information belonging to a particular Arduino
class LedStrip
{
  String portName;
  StripListener listener;

  public LedStrip(PApplet parent, String portName, int baudrate)
  {
    this.portName = portName;

    //Make a new StripListener and start its thread
    Serial serial = new Serial(parent, portName, baudrate);
    listener = new StripListener(serial, portName);
    (new Thread(listener)).start();

    println("Made new strip with name", portName);
  }

  public void setMessage(StripMessage message)
  {
    listener.setMessage(message);
  }
}

class StripMessage
{
  byte command;
  byte value;
  byte data1;
  byte data2;
  byte data3;
  byte data4;

  public StripMessage(char command, byte value, byte r, byte g, byte b, byte w)
  {
    this.command = (byte) (byte(command) & 0xff);
    this.value = (byte)(value & 0xff);
    data1 = (byte) (r & 0xff);
    data2 = (byte) (g & 0xff);
    data3 = (byte) (b & 0xff);
    data4 = (byte) (w & 0xff);
  }

  //Returns this message as a properly formatted 7-byte array, like the Arduino expects it
  byte[] getMessageAsByteArray()
  {
    byte checkSum = (byte) (byte('m') + command + value + data1 + data2 + data3 + data4);
    checkSum = (byte) (checkSum & 0xff);
    return new byte[]{'m', command, value, data1, data2, data3, data4, checkSum};
  }
}

class StripListener implements Runnable
{
  Serial serial;
  String portName;

  //Runs until this variable is false
  boolean running = true;

  //Keeps track of the current Arduino state - if the Arduino sends 'u', this variable turns false and message sending is suspended
  boolean halt = false;



  //The next scheduled message, as a byte array
  byte[] messageByte;

  //If set to true, the message will be communicated to the Arduino as soon as allowed
  boolean sendMessage = false;

  StripListener(Serial serial, String portName)
  {
    this.serial = serial;
    this.portName= portName;
  }

  public void run()
  {
    while (running)
    {
      synchronized(this)
      {
        if (serial.available() > 1)
        {
          //A message arrived!
          int message = serial.read();

          //If success is false, the message should be resent
          boolean success = false;

          if (char(message) == 'a')
          {
            success = true;
          } else if (char(message) == 'u') halt = true;
          else if (char(message) == 's') halt = false;
          else if (char(message) == 'e') 
          {
            //You can remove these printlns if they're annoying
            println("The Arduino received an invalid message!");
            success = false;
          }

          //A checksum always follows a status byte
          int checksum = serial.read();
          if (success) 
          {
            success = checksum((byte) (checksum & 0xff));
            if (!success)
            {
              println("Checksum failed! Resending message...");
            }
          }

          //Send message again if an error occurred
          if (!success) sendMessage = true;
        }

        //If allowed, send the message
        if (!halt && sendMessage)
        {
          sendMessage = false;
          sendDataToStrip();
        }
      }
    }
  }

  public void sendDataToStrip()
  {

    if (messageByte != null)
    {
      serial.write(messageByte);
    }
  }


  //Performs the checksum (simply adding all bytes together)
  public boolean checksum(byte checksum)
  {

    int check = 0;
    if (messageByte != null)
    {
      for (byte b : messageByte)
      {
        check += (b & 0xff);
      }

      check = (byte) (check & 0xff);

      return checksum == check;
    }
    return false;
  }

  public synchronized void setMessage(StripMessage message)
  {
    messageByte = message.getMessageAsByteArray();
    //If a new message is set, send it as soon as possible
    sendMessage = true;
  }

  //Don't leave loose ends dangling
  public void dispose()
  {
    running = false;
    serial.dispose();
  }
}
