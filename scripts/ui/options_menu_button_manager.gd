## Options Menu Button Manager.
##
## Handles the options menu button functionality. [br]
##
## [br]
## 
## Path: [code]res://scripts/ui/options_menu_button_manager.gd[/code]


class_name OptionsMenuButtonManager
extends TextureButton


## Signal handler for when the options menu button is pressed. [br]
##
## [br]
##
## Loads the options menu scene and adds it to the scene tree.
func _on_options_menu_button_pressed() -> void:
	var options_menu: CanvasLayer = load(GlobalVariables.OPTIONS_MENU_SCENE_PATH).instantiate()
	get_parent().get_parent().add_child(options_menu)


## Sets up button connection when the node is ready.
func _ready() -> void:
	# Connect pressed button signal
	self.pressed.connect(_on_options_menu_button_pressed)
