public void initGui()
{
  //load all ControlP5 elements 

  addClientButton = gui.addButton("addClientButton")
    .setPosition(160, (clients.size())*75+35)
    .setSize(40, 40)
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      try
      {
        if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
        {
          addClient = true;
        }
      }
      catch(Exception e)
      {
        e.printStackTrace();
      }
    }
  }
  )
  .setCaptionLabel("+");
  addClientButton.getCaptionLabel().alignX(CENTER).alignY(CENTER);

  gui.addButton("execute")
    .setPosition(370, 20)
    .setSize(115, 30)
    .getCaptionLabel().alignX(CENTER).alignY(CENTER);

  gui.addToggle("autoUpdate")
    .setPosition(490, 20)
    .setSize(115, 30)
    .setCaptionLabel("Auto update")
    .getCaptionLabel().alignX(CENTER).alignY(CENTER);

  colour1 = gui.addColorWheel("c1")
    .setRGB(color(255, 0, 0))
    .setPosition(370, 60)
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        c1red.setValue((int)red(c1)+"");
        c1green.setValue((int)green(c1)+"");
        c1blue.setValue((int)blue(c1)+"");
        c1Changed = true;
      }
    }
  }
  )
  ;

  colour2 = gui.addColorWheel("c2")
    .setRGB(color(0, 255, 0))
    .setPosition(370, 360)
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        c2red.setValue((int)red(c2)+"");
        c2green.setValue((int)green(c2)+"");
        c2blue.setValue((int)blue(c2)+"");
        c2Changed = true;
      }
    }
  }
  )
  ;

  white1Slider = gui.addSlider("white1")
    .setPosition(590, 60)
    .setSize(15, 200)
    .setRange(0, 255)
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        c1white.setValue((int)white1+"");
        c1Changed = true;
      }
    }
  }
  )
  .setCaptionLabel("White");
  white1Slider.getCaptionLabel().alignX(CENTER);

  white2Slider = gui.addSlider("white2")
    .setPosition(590, 360)
    .setSize(15, 200)
    .setRange(0, 255)
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        c2white.setValue((int)white2+"");
        c2Changed = true;
      }
    }
  }
  )
  .setCaptionLabel("White");
  white2Slider.getCaptionLabel().alignX(CENTER);

  c1red = gui.addTextfield("c1red")
    .setPosition(370, 280)
    .setSize(55, 15)
    .setValue((int)red(c1)+"")
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        colour1.setRGB(color(int(theEvent.getController().getStringValue()), green(c1), blue(c1)));
        c1Changed = true;
      }
    }
  }
  )
  .setAutoClear(false);
  c1red.setCaptionLabel("Red").getCaptionLabel().alignX(RIGHT).alignY(CENTER);

  c1green = gui.addTextfield("c1green")
    .setPosition(430, 280)
    .setSize(55, 15)
    .setValue((int)green(c1)+"")
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        colour1.setRGB(color(red(c1), int(theEvent.getController().getStringValue()), blue(c1)));
        c1Changed = true;
      }
    }
  }
  )
  .setAutoClear(false);
  c1green.setCaptionLabel("Green").getCaptionLabel().alignX(RIGHT).alignY(CENTER);

  c1blue = gui.addTextfield("c1blue")
    .setPosition(490, 280)
    .setSize(55, 15)
    .setValue((int)blue(c1)+"")
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        colour1.setRGB(color(red(c1), green(c1), int(theEvent.getController().getStringValue())));
        c1Changed = true;
      }
    }
  }
  )
  .setAutoClear(false);
  c1blue.setCaptionLabel("Blue").getCaptionLabel().alignX(RIGHT).alignY(CENTER);

  c1white = gui.addTextfield("c1white")
    .setPosition(550, 280)
    .setSize(55, 15)
    .setValue((int)white1+"")
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        white1Slider.setValue( int(theEvent.getController().getStringValue()));
        c1Changed = true;
      }
    }
  }
  )
  .setAutoClear(false);
  c1white.setCaptionLabel("White").getCaptionLabel().alignX(RIGHT).alignY(CENTER);

  c2red = gui.addTextfield("c2red")
    .setPosition(370, 580)
    .setSize(55, 15)
    .setValue((int)red(c2)+"")
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        colour2.setRGB(color(int(theEvent.getController().getStringValue()), green(c2), blue(c2)));
        c2Changed = true;
      }
    }
  }
  )
  .setAutoClear(false);
  c2red.setCaptionLabel("Red").getCaptionLabel().alignX(RIGHT).alignY(CENTER);

  c2green = gui.addTextfield("c2green")
    .setPosition(430, 580)
    .setSize(55, 15)
    .setValue((int)green(c2)+"")
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        colour2.setRGB(color(red(c2), int(theEvent.getController().getStringValue()), blue(c2)));
        c2Changed = true;
      }
    }
  }
  )
  .setAutoClear(false);
  c2green.setCaptionLabel("Green").getCaptionLabel().alignX(RIGHT).alignY(CENTER);

  c2blue = gui.addTextfield("c2blue")
    .setPosition(490, 580)
    .setSize(55, 15)
    .setValue((int)blue(c2)+"")
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        colour2.setRGB(color(red(c2), green(c2), int(theEvent.getController().getStringValue())));
        c2Changed = true;
      }
    }
  }
  )
  .setAutoClear(false);
  c2blue.setCaptionLabel("Blue").getCaptionLabel().alignX(RIGHT).alignY(CENTER);

  c2white = gui.addTextfield("c2white")
    .setPosition(550, 580)
    .setSize(55, 15)
    .setValue((int)white2+"")
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        white2Slider.setValue( int(theEvent.getController().getStringValue()));
        c2Changed = true;
      }
    }
  }
  )
  .setAutoClear(false);
  c2white.setCaptionLabel("White").getCaptionLabel().alignX(RIGHT).alignY(CENTER);



  effect = gui.addRadioButton("effect")
    .setPosition(370, 660)
    .setSize(235, 20)
    .addItem("Rainbow", 0)
    .addItem("Strobe", 1);

  for (Toggle t : effect.getItems()) 
  {
    t.getCaptionLabel().alignX(CENTER).alignY(CENTER);
  }

  gui.addSlider("value")
    .setPosition(370, 630)
    .setSize(235, 15)
    .setRange(0, 255)
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
      {
        fxChanged = true;
      }
    }
  }
  )
  .setCaptionLabel("Value").getCaptionLabel().alignX(RIGHT).alignY(CENTER);




  gui.addButton("load")
    .setPosition(700, 20)
    .setSize(115, 30)
    .setCaptionLabel("Load settings")
    .getCaptionLabel().alignX(CENTER).alignY(CENTER);

  gui.addButton("saveSettings")
    .setPosition(820, 20)
    .setSize(115, 30)
    .setCaptionLabel("Save settings")
    .getCaptionLabel().alignX(CENTER).alignY(CENTER);


  gui.addSlider("fadeSpeed")
    .setPosition(700, 100)
    .setSize(235, 15)
    .setScrollSensitivity(0.01)
    .setDecimalPrecision(3)
    .setRange(0, 0.2)
    .setCaptionLabel("Fade speed")
    .getCaptionLabel().alignX(CENTER).alignY(CENTER);
  /*
  gui.addSlider("chaseSpeed")
   .setPosition(700, 120)
   .setSize(235, 15)
   .setScrollSensitivity(0.01)
   .setDecimalPrecision(3)
   .setRange(0, 15)
   .setCaptionLabel("Chase speed")
   .getCaptionLabel().alignX(CENTER).alignY(CENTER);
   */
  gui.addButton("clearControllers")
    .setPosition(700, 60)
    .setSize(115, 30)
    .setCaptionLabel("Clear controllers")
    .getCaptionLabel().alignX(CENTER).alignY(CENTER);


  gui.addButton("clearScenes")
    .setPosition(820, 60)
    .setSize(115, 30)
    .setCaptionLabel("Clear scenes")
    .getCaptionLabel().alignX(CENTER).alignY(CENTER);

  addSceneButton = gui.addButton("addSceneButton")
    .setPosition(800, (cues.get(activeCue).scenes.size())*75+160)
    .setSize(40, 40)
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      try
      {
        if (theEvent.getAction() == ControlP5.ACTION_BROADCAST)
        {
          addScene = true;
        }
      }
      catch(Exception e)
      {
        e.printStackTrace();
      }
    }
  }
  )
  .setCaptionLabel("+");
  addClientButton.getCaptionLabel().alignX(CENTER).alignY(CENTER);

  PGraphics playArrow = createGraphics(21, 21);
  playArrow.beginDraw();
  playArrow.fill(30, 220, 2);
  playArrow.triangle(1, 1, 1, 20, 20, 10);
  playArrow.endDraw();



  PGraphics stopRect = createGraphics(21, 21);
  stopRect.beginDraw();
  stopRect.fill(220, 20, 2);
  stopRect.rect(1, 1, 20, 20);
  stopRect.endDraw();

  gui.addToggle("playCue")
    .setPosition(700, 120)
    .addCallback(new CallbackListener()
  {
    public void controlEvent(CallbackEvent theEvent)
    {
      if (theEvent.getAction()==ControlP5.ACTION_CLICK)
      {

        setPlayCue(theEvent.getController().getValue() == 1 ? true : false);
      }
    }
  }
  )
  .setImages(playArrow, playArrow, stopRect, stopRect);

  /*
   PGraphics leftArrow = createGraphics(21, 21);
   leftArrow.beginDraw();
   leftArrow.fill(10, 50, 200);
   leftArrow.triangle(1, 10, 20, 1, 20, 20);
   leftArrow.endDraw();
   prevCue = gui.addButton("prevCue")
   .setPosition(700, 100)
   .setVisible(false)
   .setImage(leftArrow);
   
   PGraphics rightArrow = createGraphics(21, 21);
   rightArrow.beginDraw();
   rightArrow.fill(10, 50, 200);
   rightArrow.triangle(1, 1, 1, 20, 20, 10);
   rightArrow.endDraw();
   nextCue = gui.addButton("nextCue")
   .setPosition(914, 100)
   .setVisible(false)
   .setImage(rightArrow);
   
   PGraphics addCue = createGraphics(21, 21);
   addCue.beginDraw();
   addCue.fill(10, 200, 50);
   addCue.noStroke();
   addCue.rect(9, 1, 4, 20);
   addCue.rect(1, 9, 20, 4);
   addCue.endDraw();
   newCue = gui.addButton("addCue")
   .setPosition(914, 100)
   .setVisible(true)
   .setImage(addCue);
   
   
   
   
   
   cueName = gui.addTextfield("cueName")
   .setPosition(755, 102)
   .setSize(155, 18)
   .setAutoClear(false)
   .setValue(cues.get(0).cueName)
   .setCaptionLabel("");
   */
}
