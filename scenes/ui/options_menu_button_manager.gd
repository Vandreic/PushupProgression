## Options Menu Button Manager.
##
## [br]
##
## Opens the options menu. [br]
##
## [br]
## 
## Path: [code]res://src/ui/options_menu_button_manager.gd[/code]


class_name OptionsMenuButtonManager
extends TextureButton


## On options menu button pressed.
func _on_options_menu_button_pressed() -> void:
	# Instantiate options menu scene
	var options_menu: CanvasLayer = load("res://src/ui/options_menu/options_menu.tscn").instantiate()
	# Add scene to tree (Needed before modifying)
	get_parent().get_parent().add_child(options_menu)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signal
	self.pressed.connect(_on_options_menu_button_pressed)
