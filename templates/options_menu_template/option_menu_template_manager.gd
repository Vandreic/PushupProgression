class_name OptionMenuTemplateManager
extends CanvasLayer


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
	
	EventBus.apply_ui_theme_requested.connect(_apply_ui_theme)
	

## Applies the UI theme based on [member Data.current_ui_theme].
func _apply_ui_theme() -> void:
	background_panel.theme = Data.current_ui_theme
	background_panel_container.theme = Data.current_ui_theme
	
	var new_stylebox: StyleBoxFlat = _create_custom_panel_stylebox()
	background_panel.add_theme_stylebox_override("panel", new_stylebox)
	background_panel_container.add_theme_stylebox_override("panel", new_stylebox)
	

## Creates a [StyleBoxFlat] for a [Panel] based on the [member current_ui_theme]. [br]
##
## [br]
##
## This function duplicates a [Panel]'s [StyleBox] from the [member current_ui_theme] 
## and modifies its appearance according to the theme settings such as 
## background color, border width, and corner radius.
func _create_custom_panel_stylebox() -> StyleBoxFlat:
	# Duplicate panel theme stylebox from currently applied theme
	var stylebox: StyleBoxFlat = Data.current_ui_theme.get_stylebox("panel", "Panel").duplicate()
	
	# Update theme properties to match new applied theme
	for theme in Data.available_themes:
		if theme == Data.get_theme_name(Data.current_ui_theme):
			# Add rounded corners
			stylebox.bg_color = Color(Data.available_themes[theme]["color"]["primary_container"])
			stylebox.set_corner_radius_all(25)
			
			# If theme has borders, add them
			if Data.available_themes[theme]["border"] == true:
				stylebox.set_border_width_all(6)
				stylebox.border_color = Color(Data.available_themes[theme]["color"]["outline"])
	
	# Return new stylebox
	return stylebox


## Signal handler for when the [member close_button] is pressed. [br]
##
## [br]
##
## Removes the menu from the scene tree.
func _on_close_button_pressed() -> void:
	get_parent().remove_child(self)
	queue_free()
