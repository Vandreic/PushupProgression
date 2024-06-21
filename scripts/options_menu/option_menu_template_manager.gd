## Template script for options within the options menu.
##
## Provides a template for creating options menus within the main options menu, 
## such as settings, appearance, etc. It handles applying the UI theme based on
## [member GlobalVariables.current_ui_theme] and the closing functionality
## of the menu itself. [br]
##
## [br]
## 
## Path: [code]res://scripts/options_menu/option_menu_template_manager.gd[/code]


class_name OptionMenuTemplateManager
extends CanvasLayer


## Background panel.
@onready var background_panel: Panel = %BackgroundPanel

## Background panel container.
@onready var background_panel_container: PanelContainer = %BackgroundPanelContainer

## Close menu button.
@onready var close_button: Button = %CloseButton


## Setup button connections and apply UI theme when the node is ready.
func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	_apply_ui_theme()
	

## Applies the UI theme based on [member GlobalVariables.current_ui_theme].
func _apply_ui_theme() -> void:
	background_panel.theme = GlobalVariables.current_ui_theme
	background_panel_container.theme = GlobalVariables.current_ui_theme
	
	var new_stylebox: StyleBoxFlat = GlobalVariables.create_custom_panel_stylebox()
	background_panel.add_theme_stylebox_override("panel", new_stylebox)
	background_panel_container.add_theme_stylebox_override("panel", new_stylebox)


## Signal handler for when the [member close_button] is pressed. [br]
##
## [br]
##
## Removes the menu from the scene tree.
func _on_close_button_pressed() -> void:
	get_parent().remove_child(self)
	queue_free()
