


class RemoteClient
{
  //Network client to send messages to
  Client client;
  String ip;
  int port;
  int comPortId;

  String message;
  String reply;

  //the message as an array of chars
  char[] commandBytes;

  boolean comPortConnected = false;
  int comPortsConnected = 0;

  //keep track of all controlp5 objects so we can remove them dynamically
  RadioButton status;
  Textfield ipField;
  Button resetButton;
  Numberbox comportBox;

  //for colour transition
  color initialColour;
  color currentColour;
  color targetColour;
  
  //current position of currentcolour between initial & targetcolour
  float position;
  
  //toggle fading or snapping to next colour
  boolean fading = false;

  int mode = COLOUR1;
  /*
  RemoteClient()
   {
   ip = "";
   port = 8008;
   comPortId = 0;
   }
   */
  RemoteClient(String ip, int port, int comPort)
  {
    this.ip = ip;
    this.port = port;
    this.comPortId = comPort;
    client = getClient(ip, port);
    sendStatus();
    addGui();
  }

  void update()
  {
    //go smoothly from one colour to the other, if required
    if (fading)
    {
      currentColour= lerpColor(initialColour, targetColour, position);
      position+=fadeSpeed;
      sendCommand('c', (char)0, currentColour);
      if (position >=1) fading = false;
    }
  }

  void display(int x, int y)
  {
    //Display surrounding rectangle
    noFill();
    stroke(178);
    rect(x, y, 325, 65, 7);

    boolean notInTrouble = false;
    if (client != null) notInTrouble = client.active();

    //Network status rectangle
    if (notInTrouble)
    {
      fill(0, 255, 0);
    } else
    {
      fill(255, 0, 0);
    }
    noStroke();
    rect(x+5, y+5, 15, 15);

    fill(178);
    text("Network", x+25, y+15);

    //Serial port status rectangle
    if (comPortConnected)
    {
      fill(0, 255, 0);
    } else
    {
      fill(255, 0, 0);
    }
    noStroke();
    rect(x+5, y+25, 15, 15);

    fill(178);
    text("Serial ["+comPortsConnected+"]", x+25, y+35);

    fill(0);
    text(comPortId, x+8, y+37);

    fill(81);
    stroke(178);
    rect(x+5, y+45, 200, 15);

    fill(178);
    if (reply != null) text(reply, x+7, y+45, 200, 15);

    noStroke();
    switch(mode)
    {
    case COLOUR1:
      fill(red(currentColour), green(currentColour), blue(currentColour));
      rect(x+215, y+5, 2, 15);
      break;
    case COLOUR2:
      fill(red(currentColour), green(currentColour), blue(currentColour));
      rect(x+215, y+25, 2, 15);
      break;
    case EFFECT:
      fill(20, frameCount%255, 10);
      rect(x+215, y+45, 2, 15);
      break;
    }
  }

  void sendReset()
  {
    message = "reset\n"+new String(new char[]{(char)comPortId, 0, 0, 0, 0, 0, 0});
    sendMessage();
  }

  void sendStatus()
  {
    message = "status\n"+new String(new char[]{(char)comPortId, 0, 0, 0, 0, 0, 0});
    sendMessage();
  }

  void sendCurrentColour()
  {
    sendCommand('c', (char)0, currentColour);
  }

  void sendCommand(char command, char value, color c)
  {
    message = "strip command\n";
    commandBytes = new char[]{(char)comPortId, command, value, (char) ((c >> 16) & 0xff), (char) ((c >> 8) & 0xff), (char) ((c ) & 0xff), (char) ((c >> 24) & 0xff)};
    sendMessage();
  }



  void sendMessage()
  {
    if (client != null && message != null) 
    {
      byte[] messageBytes;
      if (commandBytes == null)
      {
        messageBytes = parseBytes(message);
      } else messageBytes = concat(parseBytes(message), byte(commandBytes));
      client.write(messageBytes);
    }
  }

  byte[] parseBytes(String s)
  {
    byte[] b = new byte[s.length()];
    int i = 0;
    for (char c : s.toCharArray())
    {
      b[i++] = byte(c);
    }
    return b;
  }

  void listen()
  {
    if (client != null && client.available()>0)
    {
      reply = client.readString();
      //println(reply);

      pushReplyToOtherClients(reply, ip);
    }
  }

  void parseReply()
  {
    if (reply.startsWith("Connected strips:"))
    {
      //Reply to status message!
      String[] replyParse = split(reply, ' ');
      comPortsConnected = int(replyParse[2]);
      //theoretically we could store the com port name here to verify it's the same but meh
      //I haven't been too careful with keeping track which connector is what anyway
      comPortConnected = comPortsConnected > 0 && comPortId < comPortsConnected;
    }
  }


  void setColour(color c, int white)
  {
    initialColour = currentColour;
    targetColour = color(red(c), green(c), blue(c), white);
    position = 0;
    fading= true;
  }

  void addGui()
  {
    int i = clients.size();

    resetButton = gui.addButton("reset"+frameCount+random(10000000))
      .setPosition(110, 25+75*i)
      .setSize(50, 15)

      .addCallback(new CallbackListener()
    {
      public void controlEvent(CallbackEvent theEvent)
      {
        if (theEvent.getAction()==ControlP5.ACTION_CLICK)
        {
          sendReset();
        }
      }
    }
    )
    ;
    resetButton.setCaptionLabel("Reset")
      .getCaptionLabel().alignX(CENTER).alignY(CENTER);
    ;

    ipField = gui.addTextfield(ip+comPortId+"ip"+frameCount+random(10000000))
      .setPosition(110, 45+75*i)
      .setSize(115, 15)
      .addCallback(new CallbackListener()
    {
      public void controlEvent(CallbackEvent theEvent)
      {
        if (theEvent.getAction()==ControlP5.ACTION_BROADCAST)
        {
          ip = theEvent.getController().getStringValue();
          client = getClient( ip, port);
        }
      }
    }
    )
    .setAutoClear(false)
      .setValue(ip);
    ipField.setCaptionLabel("IP").getCaptionLabel().alignX(RIGHT).alignY(CENTER);

    comportBox = gui.addNumberbox(ip+comPortId+"comport"+frameCount+random(10000000))
      .setPosition(165, 25+75*i)
      .setSize(60, 15)
      .setValue((int)comPortId)
      .setScrollSensitivity(0.01)
      .setRange(0, 64)
      .setDecimalPrecision(1)
      .onEndDrag(new CallbackListener()
    {
      public void controlEvent(CallbackEvent theEvent)
      {
        comPortId = (int)theEvent.getController().getValue();
      }
    }
    );
    comportBox.setCaptionLabel("Serial").getCaptionLabel().alignX(RIGHT).alignY(CENTER);


    status = gui.addRadioButton(ip+comPortId+"status"+random(255))
      .setPosition(240, 75*i+25)
      .setSize(100, 15)
      .setSpacingRow(5)
      .addItem("C1"+frameCount+random(999999), COLOUR1)
      .addItem("C2"+frameCount+random(999999), COLOUR2)
      .addItem("FX"+frameCount+random(999999), EFFECT);

    status.getItem(0).setCaptionLabel("C1").getCaptionLabel().alignX(CENTER).alignY(CENTER);
    status.getItem(1).setCaptionLabel("C2").getCaptionLabel().alignX(CENTER).alignY(CENTER);
    status.getItem(2).setCaptionLabel("FX").getCaptionLabel().alignX(CENTER).alignY(CENTER);

  }

  void removeGui()
  {
    gui.remove(status.getName());
    gui.remove(comportBox.getName());
    gui.remove(resetButton.getName());
    gui.remove(ipField.getName());
  }
}
