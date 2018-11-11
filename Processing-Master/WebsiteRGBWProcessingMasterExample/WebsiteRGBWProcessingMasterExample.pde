import controlP5.*;
import processing.net.*;


//All the remote client sketches
ArrayList<RemoteClient> clients = new ArrayList();

//Preset list
ArrayList<Cue> cues = new ArrayList();

int activeCue = 0;


ControlP5 gui;

//GUI elements we need a global reference for
Button addClientButton, addSceneButton, prevCue, nextCue, newCue;
RadioButton effect;
ColorWheel colour1, colour2;
Slider white1Slider, white2Slider;
Textfield c1red, c1green, c1blue, c1white, c2red, c2green, c2blue, c2white, cueName;

//global colour variables (+white)
color c1, c2;
float white1, white2;

//detect changes
boolean c1Changed = false, c2Changed = false, fxChanged = false;
boolean autoUpdate = false;
boolean loading = false;
boolean addClient= false;
boolean addScene = false;

public final static int COLOUR1 = 0, COLOUR2 = 1, EFFECT = 2;

//the value slider (effect parameter)
float value = 10;

//the fade slider
float fadeSpeed = 0.01;

//the chase speed slider
float chaseSpeed = 1;




void setup()
{
  size(1200, 800);


  gui = new ControlP5(this);

  //Necessary to avoid concurrent modification error while loading in settings
  //Drawing the GUI can temporarily be suspended while settings load
  gui.setAutoDraw(false);

  cues.add(new Cue());

  initGui();


  surface.setLocation(20, 20);
  surface.setResizable(true);

  File autosave = new File(sketchPath()+"/data/Autosave.rgbw");
  if (autosave.exists())
  {
    selectLoadLocation(autosave);
  }

  PFont font = createFont("Arial", 12);
  textFont(font);


  println("Master control sketch booted in", millis(), "ms.");
}

void draw()
{
  background(0);

  if (activeCue < cues.size())
  {
    Cue cue = cues.get(activeCue);
    cue.update();
    cue.display();
  }

  int x = 20, y = 20;

  //Display and update all remote clients (left column)
  for (int i = 0; i < clients.size(); i++)
  {
    RemoteClient client = clients.get(i);

    client.update();

    if (autoUpdate)
    {
      if (c1Changed && (int) client.status.getValue() == COLOUR1)
      {
        client.currentColour = color(red(c1), green(c1), blue(c1), white1);

        client.fading = false;
        client.sendCurrentColour();
        client.mode = COLOUR1;
      } else
        if (c2Changed && (int) client.status.getValue() == COLOUR2)
        {
          client.currentColour = color(red(c2), green(c2), blue(c2), white2);
          client.fading = false;
          client.sendCurrentColour();
          client.mode = COLOUR2;
        } else if ((fxChanged || c1Changed) && (int) client.status.getValue() == EFFECT)
        {
          client.sendCommand(getCurrentEffect(), (char)value, color(red(c1), green(c1), blue(c1), white1));
          client.mode = EFFECT;
        }
    }

    //Every second, poll its status
    if (frameCount%60==0) client.sendStatus();

    //Check for incoming messages
    client.listen();

    boolean notInTrouble = false;

    //only after writing the above I realised the RemoteClient's P5.net Client is also called "client"
    //it's staying like this
    if (client.client != null) notInTrouble = client.client.active();

    //If something went wrong, try to reestablish a network connection every second
    if (!notInTrouble && frameCount%60==0)
    {
      client.client = new Client(this, client.ip, client.port);
    }

    client.display(x, y);


    y+=75;
  }

  //reset the keep-trackers
  c1Changed = false;
  c2Changed = false;
  fxChanged = false;

  //This is necessary to avoid concurrent modification errors
  if (addClient)
  {
    addClient = false;
    addClient();
  }

  //Same but for new scenes in the current cue
  if (addScene)
  {
    addScene = false;
    addScene();
  }

  //Suspend drawing GUI while settings file is loaded to avoid concurrent modification errors
  if (!loading) gui.draw();
}

void mousePressed()
{
}

//Searches current clients for the given ip & port
//If no such clients are found, a new one is returned
//This way multiple strips on the receiver can easily use the same client
Client getClient(String ip, int port)
{
  for (RemoteClient c : clients)
  {
    if (c.client != null)
    {

      if (c.client.ip() != null && c.client.ip().equals(ip)) 
      {
        return c.client;
      }
    }
  }
  println("no existing clients found, making new one at ip", ip);
  return new Client(this, ip, port);
}

//Callback for the Execute button: send values to the controllers
public void execute()
{
  for (RemoteClient c : clients)
  {
    switch((int)c.status.getValue())
    {
    case COLOUR1:
      c.setColour(c1, (int)white1);
      c.mode = COLOUR1;
      break;
    case COLOUR2:
      c.setColour(c2, (int)white2);
      c.mode = COLOUR2;
      break;
    case EFFECT:
      c.sendCommand(getCurrentEffect(), (char)value, color(red(c1), green(c1), blue(c1), white1));
      c.mode = EFFECT;
      break;
    default:
      //do nothing I guess
      break;
    }
  }
}


//convenience methods
char getEffect(int fx)
{
  switch(fx)
  {
  case 0:
    return 'r';

  case 1 :
    return 's';
  }
  return 0;
}

char getCurrentEffect()
{
  return getEffect((int)effect.getValue());
}

//Add a new client 
void addClient(String ip, int port, int comPort)
{
  //Create the GUI elements corresponding to this RemoteClient
  addClientButton.setPosition(addClientButton.getPosition()[0], addClientButton.getPosition()[1]+75);

  RemoteClient newClient = new RemoteClient(ip, port, comPort);



  clients.add(newClient);
}

//"+" button callback
void addClient()
{
  addClient("", 8008, 0);
}

//"+" button callback
void addScene()
{
  addScene("Scene " + (cues.get(activeCue).scenes.size()+1), new ArrayList<State>());
}

void addScene(String  name, ArrayList<State> states)
{
  cues.get(activeCue).addScene(name, states);
  addSceneButton.setPosition(addSceneButton.getPosition()[0], addSceneButton.getPosition()[1]+75);
}

//switch playing cues
void setPlayCue(boolean playing)
{
  if (cues.size() > 0 && cues.size() > activeCue) cues.get(activeCue).playing = playing;
}



//The reply to the "status" poll message is only parsed by one client
//this method is called when that message is received so the others can get the status too
void pushReplyToOtherClients(String reply, String ip)
{
  for (RemoteClient c : clients)
  {
    if (c.ip.equals(ip)) 
    {
      c.reply = reply;
      c.parseReply();
    }
  }
}

//load button callback
public void load()
{
  selectInput("Select a .rgbw configuration file", "selectLoadLocation");
}

//load file selected callback
public void selectLoadLocation(File location)
{

  try
  {
    if (location == null) return;



    //file parsing
    XML file = loadXML(location.getAbsolutePath());


    XML output = file.getChild("outputs");
    XML[] outputs = output.getChildren("output");
    XML scene = file.getChild("scenes");
    XML[] scenes = scene.getChildren("scene");

    clearControllers();
    clearScenes();

    //Disable GUI drawing to avoid concurrent modification errors
    loading = true;

    //add all RemoteClients from the save file
    int i = 0;
    for (XML o : outputs)
    {
      addClient(o.getString("ip"), o.getInt("port"), o.getInt("comPort"));
    }
    for (XML s : scenes)
    {
      ArrayList<State> states= new ArrayList();
      int j = 0;
      for (XML state : s.getChildren("state"))
      {
        println(j);
        State st = new State();
        st.controller = clients.get(j++);
        st.status = state.getInt("status");
        st.effect = state.getInt("effect");
        st.valueS = state.getFloat("value");
        st.white= state.getInt("white");
        st.colour = state.getInt("colour");
        states.add(st);
      }
      cues.get(activeCue).addScene(s.getString("name"), states, s.getInt("setting"), s.getFloat("duration"));
    }
  }
  catch(Exception e)
  {
    e.printStackTrace();
  }
  loading = false;
}


//save button callback
public void saveSettings()
{
  selectOutput("Select where to write configuration to", "selectSaveLocation");
}

//save file selected callback
public void selectSaveLocation(File location)
{
  if (location == null) return;
  XML file = new XML("settings");
  XML output = file.addChild("outputs");
  for (RemoteClient client : clients)
  {
    XML c = output.addChild("output");
    c.setString("ip", client.ip);
    c.setInt("port", client.port);
    c.setInt("comPort", client.comPortId);
    c.setInt("status", (int)client.status.getValue());
  }
  XML scenes = file.addChild("scenes");
  for (Scene scene : cues.get(activeCue).scenes)
  {
    XML s = scenes.addChild("scene");
    s.setString("name", scene.name);
    s.setFloat("duration", scene.duration.getValue());
    s.setInt("setting", (int)scene.setting.getValue());
    for (State state : scene.states)
    {
      XML stateValue = s.addChild("state");
      stateValue.setInt("status", state.status);
      stateValue.setInt("colour", state.colour);
      stateValue.setInt("white", state.white);
      stateValue.setInt("effect", state.effect);
      stateValue.setFloat("value", state.valueS);
    }
  }
  String locationParsing = location.getAbsolutePath();
  if (!locationParsing.endsWith(".rgbw")) locationParsing += ".rgbw";
  saveXML(file, locationParsing);
}

//remove all RemoteClients
void clearControllers()
{
  loading = true;
  //reset the gui
  for (RemoteClient client : clients)
  {
    client.removeGui();
  }

  //reset the clients
  clients.clear();

  addClientButton.setPosition(160, (clients.size())*75+35);

  loading = false;
}

//remove all scenes
void clearScenes()
{
  cues.get(activeCue).removeScenes();
}

//save current situation before exiting
public void exit()
{
  println("autosaving");
  selectSaveLocation(new File(sketchPath()+"/data/Autosave.rgbw"));
  super.exit();
}

//I tried to add the option to have more cues (list of scenes) but ControlP5 wasn't having it

/*
//More CP5 callbacks
 
 public void cueName(String name)
 {
 cues.get(activeCue).cueName = name;
 }
 
 public void prevCue()
 {
 println("prev cue");
 setCue(activeCue-1);
 }
 
 public void nextCue()
 {
 println("next cue");
 setCue(activeCue+1);
 }
 
 public void addCue()
 {
 println("adding cue");
 
 
 
 Cue newCue = new Cue();
 newCue.cueName = "Cue " + (cues.size() );
 cues.add(newCue);
 
 setCue(cues.size()-1);
 }
 
 void setCue(int cueNumber)
 {
 println("switching to cue", cueNumber, "from", activeCue);
 if (cueNumber < 0) return;
 for (Scene scene : cues.get(activeCue).scenes)
 {
 scene.destroyScene();
 }
 println("scenes destroyed of cue", activeCue);
 
 cueNumber = constrain(cueNumber, 0, cues.size()-1);
 activeCue = cueNumber;
 
 println("updated cue", activeCue);
 
 if (activeCue == 0)
 {
 prevCue.setVisible(false);
 }
 if (activeCue > 0)
 {
 prevCue.setVisible(true);
 }
 if (activeCue == cues.size()-1)
 {
 newCue.setVisible(true);
 nextCue.setVisible(false);
 } else
 {
 newCue.setVisible(false);
 nextCue.setVisible(true);
 }
 
 cueName.setValue(cues.get(activeCue).cueName);
 
 println("setting cue", activeCue, cues.get(activeCue).cueName);
 
 cues.get(activeCue).build();
 }
 
 */
