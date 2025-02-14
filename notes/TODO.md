The heading numbers (like +0, -1, +3), refer to the priority of the task. Higher numbers being what I should do first, lower numbers being what I should do last. While I do use the order that the features are written is as a rough take for what should be done first, I like the explicit priority numbers for tasks that I really should be doing in a certain order.
# MVP
I want imagine how it'll feel to be done with this project.
## +2
- [x] Make the ball a little lighter
## +1
- Sounds
	- Jump Sound
		- [x] Default jump
		- [x] Air jump
		- [x] Jump Refresh
			- I think this should be a reversed jump sound (Update: I didn't do this)
	- Collision Sound
		- [x] Collision Wall
		- [x] Collision Floor
		- [x] Rolling with velocity
			- Because of how often this'll play I may want to not use the same soundfont for this.
		- [x] Rolling against velocity
	- Level status sound
		- [x] Level Start
		- [x] Level Finish
		- [x] Collect Spoon
	- Cursor sound
		- [x] Cursor move
		- [x] Cursor select
		- [x] Cursor back
- Music or Ambiance
	- [ ] Main Menu
	- [ ] Level
		- The levels could have difference ambiance depending on how easy they are to find.
- [ ] Make sure "Next Level" is working.
- Adjust level "Up the Stairs"
	- [ ] For better perspective
	- [ ] Remove or simplify secret section
	- [ ] Make moving block way way slower
- [ ] Label "Collected Spoons" on level select
- Make 5 more levels, then split the levels into two worlds
	- [ ] Make a level template and copy paste it a bunch, if I ever come back to this project I'll want to streamline this process.
- [ ] World 2 unlocks after finishing so many levels
- [ ] Is there any way I can fix shader caching?
	- Where / when does the game lag?
		- Collecting a Spoon
- Rumble
	- [ ] On player collision.
		- Colliding with the floor or wall
	- [ ] (Maybe) when moving against current velocity
	- [ ] Level Start
	- [ ] Level Finish
	- [ ] Enable / Disable option
## +0
- [ ] Add timer
## -1
- [ ] Write about my feelings about the project within the game.
- [ ] Adjust credits reflect my current socials.
- If I feel like it; make the game have a better aesthetic. Parts that could use improvement:
	- [ ] Level Backgrounds
	- [ ] Roll'n Around title
	- [ ] Title Screen Background
		- An idea; "wiggle gradient"
## -2
- [ ] Figure out if I should make the video before releasing the game to itch as I might want to package the video with the game itself. I should but the video into an "Extras" menu if I put it in the game.
- [ ] Inspect "TODO"s in the game's code.
- [ ] Release game to itch!!!!!!!
#  OLD MVP
This is my old MVP, I've decided I want to work on less so I can move to other projects. I want to keep this here so certain ideas are kept in mind.
## +2
- I want to make a level tool so it's easy manipulating levels within the project.
- [[Level Objects#Area Trigger|Area Triggers]]
	- Clearly define [[Level Objects#Area Trigger|Area Triggers]] with a line on the ground and a visible spotted wall when the player approaches it for clear representation.
	- Graphic when paused
	- Bar at bottom of screen indicating how long the transition will take.
- Implement Timer
## +1
- Finish 10 levels.
## +0
- Change levels from loading on hover to a preview image (preview images generate with a tool within the engine).
- Adjust credits reflect my current socials.
- Remove UIScale node from everything in the project.
## -2
- Look through each file and folder and make sure it doesn't have any obvious mistakes. I don't want to spend more than 30 seconds on any file. Write down things that I may want changed but I don't have the time for in the moment. Publishing comes first.
- Remove z_old_ files
## -3
- Publish git repo
- Publish to itch.io
# Polish after publish
## +3
- Integrate mouse control for movement.
- Change [[Level Objects#Goal|Goal]] particles to something else as the Compatibility renderer cannot render them.
- Integrate jumping for multi touch.
	- When holding pressing on a screen (mobile), when another touch is registered, make the player jump.
- Allow [[Level Objects#Spring|Spring]] to be recolored (I might make a whole palette system for this)
### Sounds!
- The different jumps
- Touching wall
- Jump refresh
- Rolling
### Background noise
- Do I want ambiance?
- Do I want music?
## +2
- Ready -> Start! Level intro thing~
- Trail of where rolled around.
## 0
- Make Add-on for Level where, on save, connects game_mode_setup signal to specific defined nodes...
	- Such as:
		- Spoon
		- Two Point Moving Node
		- Area Transition
	-  This would remove the need for the level_setup / game_mode_setup signal in the Roll'n Around node (RA). 
	- After this is done, delete / remove <code>get_level</code> and <code>get_game_mode</code> code and files.
- Update <code>moving_platform.tscn</code> in a number of ways I cannot remember but I'll write down the ways that I can.
	- Move all code to an add on.
	- Move baking related code to an add-on and not in the <code>moving_platform.gd</code> file. 
- Rename GameModeSoloLevel and solo_level instances to GoalGameMode and goal_game_mode.
- Separate the Spoon related code into nodes separate from GameModeSoloLevel or GoalGameMode (if finished renaming GameModeSoloLevel).
## -1
- I want to remove all the code from <code>main.tscn</code> except for code that initializes the game.
- There was an attempt to make this game multi-threaded early on. I believe I removed most code for multi-threading at some point. I should try to either remove the rest of the multi-threading code artifacts or get multi-threading working again.
- Replace usage of Godot Groups with a Singleton with signals (personal preference, signals are more explicit than groups).
- Integrate bake tools into a Godot Editor Plugin as apposed to a script launched from the game. The current bake tools are located in project/tools.
- Maybe integrate my "CustomFocus" I use in Pal'n Around for better UX.