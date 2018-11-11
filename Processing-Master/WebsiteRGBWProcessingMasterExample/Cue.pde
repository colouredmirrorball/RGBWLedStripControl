//a Cue is a list of Scenes
//Originally I wanted to have the option to create more lists at runtime but it's getting late
//having multiple cues is now officially out of scope :P
//the framework is there

class Cue
{
  ArrayList<Scene> scenes = new ArrayList();

  String cueName = "Default";

  int activeScene = 0;
  boolean playing = false;
  float prevTime = millis();

  public Cue()
  {
    Scene firstScene = new Scene();
    firstScene.name = "Scene " + (scenes.size()+1);

    firstScene.buildScene(700, 150);
    scenes.add(firstScene);
  }

  public Scene addScene(String name, ArrayList<State> states)
  {
    return addScene(name, states, 0, 1);
  }

  public Scene addScene(String name, ArrayList<State> states, int setting, float duration)
  {
    Scene newScene = new Scene();
    buildScene(newScene, scenes.size());
    newScene.name = name;
    newScene.setting.setValue(setting);
    newScene.duration.setValue(duration);

    newScene.states.addAll(states);

    scenes.add(newScene);

    addSceneButton.setPosition(800, (cues.get(activeCue).scenes.size())*75+160);

    return newScene;
  }

  void build()
  {
    int i = 0;
    for (Scene s : scenes)
    {
      buildScene(s, i++);
    }
  }

  void buildScene(Scene scene, int i)
  {
    scene.buildScene(700, i*75+150);
  }

  void removeScenes()
  {
    for (Scene s : scenes)
    {
      s.destroyScene();
    }
    for (int i = scenes.size()-1; i >= 0; i--)
    {
      scenes.remove(i);
    }

    addSceneButton.setPosition(800, (cues.get(activeCue).scenes.size())*75+160);
  }

  void update()
  {
    float intTime = 1000*scenes.get(activeScene).duration.getValue();
    if (playing && millis() - prevTime > intTime)
    {
      prevTime = millis();
      if (activeScene < scenes.size()) scenes.get(activeScene).stop();
      activeScene++;
      if (activeScene >= scenes.size()) activeScene = 0;
      if (scenes.size() > 0 && activeScene < scenes.size())
      {
        scenes.get(activeScene).recall();
      }
    }
  }

  void display()
  {
    int x = 700, y = 150;
    for (int i = 0; i < scenes.size(); i++)
    {
      Scene scene = scenes.get(i);
      scene.display(x, y);
      y+=75;
    }
  }
}
