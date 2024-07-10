class_name OptionsMenuButtonManager
extends TextureButton


## Options Menu Button Manager.
##
## Handles the options menu button functionality. [br]
##
## [br]
## 
## Path: [code]res://scripts/ui/options_menu_button_manager.gd[/code]


## Signal handler for when the options menu button is pressed. [br]
##
## [br]
##
## Loads the options menu scene and adds it to the scene tree.
func _on_options_menu_button_pressed() -> void:
	SceneManager.add_scene_requested.emit("OptionsMenu")


## Sets up button connection, when the node is ready.
func _ready() -> void:
	self.pressed.connect(_on_options_menu_button_pressed)
