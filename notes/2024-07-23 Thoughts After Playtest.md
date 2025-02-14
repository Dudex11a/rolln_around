## What might need work

| The controls were frustrating because of the lack of control (or maybe the feedback associated with the controls?). |
| ------------------------------------------------------------------------------------------------------------------------------ |
| I think I need to do multiple things to solve this issue.<br>- Better Feedback (Sounds and maybe a visual for momentum)        |

***

| Had trouble with perspective                              |
| ----------------------------------------------------------------- |
| I can use different camera angles and on screen indications to help with this. |

***
***

I feel at a slight loss for what to do even after writing what I have. I know I have more specific instruction elsewhere as well... I think I just need to work on stuff. My emotions aren't aligning with what I logically think progress is and it's confusing me. Quite frankly, this has been confusing me for a long time. My emotions don't have enough "self correction" to align with what I think is logically good.

Part of my issue is that I'm working on backing up some files right now. It's taking focus away from potentially working on Roll'n Around.

So what I need to do is specifically target an aspect of Roll'n Around I think I should work on. I want to make the MVP, get the game working first, even if it's bad. The "even if it's bad" aspect upsets me but I think I'm realizing just how important it is with how I can show Roll'n Around off pretty well even now before it's finished.

What's the next thing?
- I want to make a level tool so it's easy manipulating levels within the project.
- I want levels to lead into the next more seamlessly
Are these necessary? Not really but it'll make working on the project more appealing.

What makes it hard to make levels right now? or what is the process for making levels?
THIS IS A WIP, A LOT OF PARTS DON'T MAKE SENSE RIGHT NOW
- Parts
	- Menu
	- Level scene
	- Level geometry from Blender
- Tools I can make
	- World and Level manager
	- Manage levels in level select
		- Global Options
			- Add level
			- Generate Level Select
		- Displays list of world "items"
			- Delete World
			- Parameters
			- BAKING
				- 
		- Displays list of level "items"
			- Remove level
			- BAKING
				- Level Select
					- Spoons
						- Spoons collected icon and find-able spoons
					- Level preview
						- Take screenshot of the level
					- Name
		- Save all information to a unique object with inst_to_dict / dict_to_inst
	- Manage level scenes
		- Displays list of level "items"
		- Global Options
			- Create level
		- Level item options
			- Delete level
			- Parameters
				- Name
			- Create Blender file for level
			- Open Blender file (if there is one, there should be)
			- Open Scene
## World / Level Manager
![[world_level_editor.excalidraw]]
### What gets baked

I think I need to make a mock-up of the level select as I don't like the way it looks right now, I'd like the UI to go something like; World Select -> Level Select