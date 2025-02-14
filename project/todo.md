* Todo:

EDITOR DEBUGGER

Making tool script that launches a specific level
- Make Tool as child in 
- Make sure I can get launch parameters
- Setting launch parameters to level id
- Make so game with level id goes to level

-----
- Work on levels
  - Line on floor for transitions (later try making it work in it's own project or something)
  - Speed Boost
    - ~ Flashing pad lights, 3 arrows on pad, the light moves forward through the arrows, strange energy to the pad under the arrows. : 8/16/2022
    - Tween for speed up (add)
    - Tween for slow down for not intended direction (subtract)
  - Make 5 levels
    - Don't forget spoons!
    - Aspects for tutorial levels
- Report parser issue in Moving Platform
- Sounds
- Work on player setup / Multiplayer
  - Multiplayer spawning
  - area_transition dragging
  - Latch to top if jump on top
- Options
  - Remember to search OPTION in code
- Level aspects
  - Bumper
  - Checkpoints
  - Unlocking levels / Level Completion
- Make 15 more levels
- Check licensing on stuff
  - Textures
- Crash reports
- Search for TEMP in code and fix that up
- Polish 1
  - Level category descriptions
  - Look at inspiration
  - Opening and closing level sections
  - Death anim
  - Jump particles
    - Dependent on situation
  - Limit colors?
  - Spawn platform
  - Change short hop so it's only 1 possible velocity
  - Delete unnecessary files
  - Play through full game, ask others
- Release on Itch !!!!!!

- Get opportunity to friends for levels
- Polish 2
  - Use little character instead of ball mode
  - Recommended player amount
  - Fancy level backgrounds?
  - Think about other particles
    - Goal
    - Spoon
  - Goal post or goals in general
  - More spicy menu
    - Better cursor
  - Toonify textures
  - Multiplayer splitscrene option
  - Have gameplay recordings be title screen
  - Path3DMultiMesh
    - Use mean rotation (between offset before and after (instead of just after)) on dots.
    - Make another MultiMeshInstance for user defined points, this is mainly for better indicators for stops.
    - Optimization
- Release Moving Platform separately to Godot asset store.

- Play another marble game (Marble Madness?) for inspiration

To Tweet or show off:
- Tweet every Wednesday and Saturday between 12 - 1 (In PI  )?
- Combine Tweets for Youtube video
- Camera system

* Done:
-----
- ~ Fix solo level ui : 7/?/2022
- ~ Faster player acceleration when velocity is low : 8/4/2022 : 11:59am
- ~ This isn't necessary, all I have to do is make sure the area triggers aren't touching. --Have a second area inside area_transition so if the Player immediately turns around a transition occurs.--
- ~ Have area_trigger not re-trigger if active when re-entering a trigger (Check camera pos?) : 8/7/2022
- ~ More appealing materials
  - ~ Make material that changes based on normals (floor, wall, ceiling)
  - ~ I ended up just finding some for now : 8/8/2022 : 4:52pm
- ~ Increase gravity (this is so the ball doesn't launch as far with the spring) (this might not be the best idea) : 8/9/2022
- ~ Jump pad
  - ~ A lot of core functionality, all I need is strength next : 8/9/2022 : 2:22am
  - ~ Implement strength : 9:30pm
  - ~ Prepare Twitter post of "I made a spring that animates procedurally based on one value": 8/11/2022 : 2:40pm
- ~ Add reset button to solo_level results UI : 8/12/2022 : 12:05am
- ~ Adjusted hold jump buffer so you have to press jump again in the air to activate : 8/12/2022 : 12:28
- Moving Platforms
  - ~ Moving platform basic functionality : 8/11/2022 : 6:30pm
  - ~ Display dotted line on curve : 8/14/2022 : 3:10am
  - ~ Schedule Tweet for this : 8/15/2022 : 4:31am
- ~ Upgrade to Godot 4 A14 from A13
- ~ Remove floor on goal??? (needs testing)


AREA TRIGGER STUFF FOR VISUALS
3 decal method:
  Have scene for screenshot of shape
  Assign outline material to mesh
  Take screenshots of sides
  Apply screenshots to decal