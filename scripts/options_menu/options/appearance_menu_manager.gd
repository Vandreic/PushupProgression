## Controls the behavior of the appearance menu.
## 
## Manages the appearance menu within the options menu, handling the 
## creation of theme options and applying selected themes. [br]
##
## [br]
##
## Path: [code]res://scripts/options_menu/options/appearance_menu_manager.gd[/code]


class_name AppearanceMenuManager
extends Panel


## Background panel.
@onready var background_panel: Panel = %BackgroundPanel

## Themes option button.
@onready var themes_option_button: OptionButton = %ThemesOptionButton


## Setup theme options and connect signals when the node is ready.
func _ready() -> void:
	# Create theme options
	_create_theme_options()
	themes_option_button.item_selected.connect(_on_themes_option_button_select)


## Creates theme options for the [member themes_option_button].
func _create_theme_options() -> void:
	for theme in GlobalVariables.available_themes:
		var theme_name: String = theme.capitalize()
		themes_option_button.add_item(theme.capitalize())
	
	# Select current theme
	themes_option_button.select(GlobalVariables.selected_theme_index)


## Signal handler for when an option inside the [member themes_option_button] is
## selected. [br]
##
## [br]
##
## Parameters: [br]
## • [code]index[/code] ([int]): The index of the item selected. See 
## [signal OptionButton.item_selected] for more details. [br]
##
## [br]
##
## Updates the selected theme index, applies the selected theme to the UI, 
## saves the data, and re-opens the appearance menu with the new theme.
func _on_themes_option_button_select(index: int) -> void:
	GlobalVariables.selected_theme_index = index
	
	# Apply new theme
	for theme in GlobalVariables.available_themes:
		var theme_name: String = theme.capitalize()
		if themes_option_button.get_item_text(index) == theme.capitalize():
			GlobalVariables.current_ui_theme = GlobalVariables.available_themes[theme]["theme"]
	
	# Apply and log theme change and save data
	GlobalVariables.apply_ui_theme(true)
	GlobalVariables.save_data()
	
	# Re-open appearance menu with new applied theme
	_reopen_menu()
	

## Re-open appearance menu with new applied theme.
func _reopen_menu() -> void:
	# Change current scene name and hide
	var current_appearance_menu: CanvasLayer = get_parent().get_parent()
	var _name: String = "Deleted" + current_appearance_menu.name
	current_appearance_menu.name = _name
	current_appearance_menu.visible = false
	
	# Instantiate and add new appearance menu scene
	var new_appearance_menu: CanvasLayer = load(GlobalVariables.APPEARANCE_MENU_SCENE_PATH).instantiate()	
	current_appearance_menu.get_parent().add_child(new_appearance_menu)
	
	# Remove current scene from tree
	current_appearance_menu.get_parent().remove_child(current_appearance_menu)
	current_appearance_menu.queue_free()
