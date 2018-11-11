class Scene
{
  //a State is a specific value for one controller (a colour, an effect, ...)
  //a Scene is a collection of controller states
  ArrayList<State> states = new ArrayList();
  String name = "Scene";

  //keep track of controlp5 objects so we can remove them later
  Slider duration;
  Toggle playButton;
  Button recordButton;
  Textfield nameBox;
  RadioButton setting;

  //build the GUI at the required coördinates
  void buildScene(int x, int y)
  {
    duration = gui.addSlider("Duration"+name+frameCount+random(9999999))
      .setPosition(x+25, y+5)
      .setSize(150, 15)
      .setRange(0, 30)
      .setScrollSensitivity(0.005)
      .setValue(1);

    duration.setCaptionLabel("Duration").getCaptionLabel().alignX(RIGHT).alignY(CENTER);


    PGraphics playArrow = createGraphics(16, 16);
    playArrow.beginDraw();
    playArrow.fill(30, 220, 2);
    playArrow.triangle(1, 1, 1, 15, 15, 8);
    playArrow.endDraw();

    PGraphics stopRect = createGraphics(16, 16);
    stopRect.beginDraw();
    stopRect.fill(220, 20, 2);
    stopRect.rect(1, 1, 16, 16);
    stopRect.endDraw();


    playButton = gui.addToggle("Play"+name+frameCount+random(9999999))
      .setPosition(x+5, y+4)
      .setImages(playArrow, playArrow, stopRect, stopRect)
      .addCallback(new CallbackListener()
    {
      public void controlEvent(CallbackEvent theEvent)
      {
        if (theEvent.getAction()==ControlP5.ACTION_CLICK && theEvent.getController().getValue() == 1)
        {
          recall();
        }
      }
    }
    );


    PGraphics recordCircle = createGraphics(16, 16);
    recordCircle.beginDraw();
    recordCircle.fill(220, 20, 2);
    recordCircle.ellipse(8, 8, 16, 16);
    recordCircle.endDraw();

    PGraphics recordCircleActive = createGraphics(16, 16);
    recordCircleActive.beginDraw();
    recordCircleActive.fill(220, 20, 2);
    recordCircleActive.stroke(210, 230, 10);
    recordCircleActive.ellipse(8, 8, 15, 15);
    recordCircleActive.endDraw();


    recordButton = gui.addButton("Record"+name+frameCount+random(9999999))
      .setPosition(x+5, y+24)
      .addCallback(new CallbackListener()
    {
      public void controlEvent(CallbackEvent event)
      {

        if (event.getAction() == ControlP5.ACTION_BROADCAST && event.getController().getValue() == 1) record();
      }
    }
    )
    .setImages(recordCircle, recordCircle, recordCircleActive, recordCircleActive);



    nameBox = gui.addTextfield("Name"+name+frameCount+random(9999999))
      .setPosition(x+25, y+25)
      .setSize(150, 15)
      .setValue(name);

    nameBox.setCaptionLabel("").getCaptionLabel().alignX(RIGHT).alignY(CENTER);



    setting = gui.addRadioButton("Setting"+name+frameCount+random(9999999))
      .setPosition(x+180, y+5)
      .setSize(50, 15)
      .setSpacingRow(5)
      .addItem("State"+name+frameCount+random(9999999), 0)
      .addItem("Value"+name+frameCount+random(9999999), 1);

    setting.getItem(0).setCaptionLabel("State").getCaptionLabel().alignX(CENTER).alignY(CENTER);
    setting.getItem(1).setCaptionLabel("Value").getCaptionLabel().alignX(CENTER).alignY(CENTER);

    setting.activate(0);
  }

  //remove dem GUI
  void destroyScene()
  {
    duration.setVisible(false).setBroadcast(false); 
    nameBox.setVisible(false).setBroadcast(false);
    //gui.remove(nameBox.getName());
    gui.remove(playButton.getName());
    gui.remove(recordButton.getName());
    gui.remove(setting.getName());
  }

  //Store the state of the controllers
  public void record()
  {
    for (RemoteClient client : clients)
    {
      State newState = new State();
      newState.controller = client;
      switch((int)setting.getValue())
      {
      case 0:
        //State: record the current state (C1, C2, ...)

        newState.status = (int)client.status.getValue();
        break;
      case 1:
        //Value: record the current colour/fx state and ignore state
        switch( (int)client.status.getValue())
        {
        case COLOUR1:
          newState.colour = c1;
          newState.white = (int)white1;
          newState.status = State.PRECOLOUR;
          break;
        case COLOUR2:
          newState.colour = c2;
          newState.white = (int)white2;
          newState.status = State.PRECOLOUR;
          break;
        case EFFECT:
          newState.colour = c1;
          newState.white = (int)white1;
          newState.status = State.PREEFFECT;
          newState.effect = getCurrentEffect();
        }
        break;
      }
      states.add(newState);
    }
  }


  public void display(int x, int y)
  {
    noFill();
    stroke(178);
    rect(x, y, 235, 65, 7);

    int xc = x+5;
    int w = (clients.size() > 0 ? 225/(clients.size()) : 0) - 5;
    for (RemoteClient client : clients)
    {
      boolean found = false;
      
      //display the recorded value of every controller (or an "X" if the controller isn't used)
      for (State state : states)
      {
        if (state.controller == client)
        {
          found = true;
          color colour = color(0);
          switch(state.status)
          {
          case COLOUR1:
            colour = c1;
            break;
          case COLOUR2:
            colour = c2;
            break;
          case State.PRECOLOUR:
            colour = state.colour;
            break;
          case EFFECT:
          case State.PREEFFECT:
            colour = color(20, frameCount%255, 10);
            break;
          }
          noStroke();
          fill(colour);
          rect(xc, y+45, w, 15);
        }
      }
      if (!found)
      {
        fill(255, 0, 0);
        text("X", xc, y+55);
      }
      xc+=w+5;
    }
  }

  //push all states to the controllers
  public void recall()
  {
    playButton.setState(true);
    for (State state : states)
    {
      state.recall();
    }
  }

  public void stop()
  {
    playButton.setState(false);
  }
}

class State
{
  RemoteClient controller;
  public final static int PRECOLOUR = 10, PREEFFECT = 11;
  int status = COLOUR1;
  color colour = color(0);
  int white = 0;
  int effect = 0;
  float valueS = 0;



  public void recall()
  {
    switch(status)
    {
    case COLOUR1:
      controller.setColour(c1, (int)white1);
      break;
    case COLOUR2:
      controller.setColour(c2, (int)white2);
      break;
    case PRECOLOUR:
      controller.setColour(colour, (int)white);
      break;
    case EFFECT:
      controller.sendCommand(getCurrentEffect(), (char)value, color(red(c1), green(c1), blue(c1), white1));
      break;
    case PREEFFECT:
      controller.sendCommand(getEffect(effect), (char)valueS, color(red(colour), green(colour), blue(colour), white));
      break;
    }
  }
}
