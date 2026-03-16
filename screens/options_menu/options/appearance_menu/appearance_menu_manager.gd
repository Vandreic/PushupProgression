class_name AppearanceMenuManager
extends Panel


## Controls the behavior of the appearance menu.
## 
## Manages the appearance menu within the options menu, handling the 
## creation of theme options and applying selected themes. [br]
##
## [br]
##
## Path: [code]res://scripts/options_menu/options/appearance_menu_manager.gd[/code]


## Background panel.
@onready var background_panel: Panel = %BackgroundPanel

## Themes option button.
@onready var themes_option_button: OptionButton = %ThemesOptionButton


## Setup theme options and connect signals, when the node is ready.
func _ready() -> void:
	# Create theme options
	_create_theme_options()
	themes_option_button.item_selected.connect(_on_themes_option_button_select)


## Creates theme options for the [member themes_option_button].
func _create_theme_options() -> void:
	for theme in Data.available_themes:
		var theme_name: String = theme.capitalize()
		themes_option_button.add_item(theme.capitalize())
	
	# Select current theme
	themes_option_button.select(Data.selected_theme_index)


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
	Data.selected_theme_index = index
	
	# Apply new theme
	for theme in Data.available_themes:
		var theme_name: String = theme.capitalize()
		if themes_option_button.get_item_text(index) == theme.capitalize():
			Data.current_ui_theme = Data.available_themes[theme]["theme"]
	
	# Update ui theme and save changes
	EventBus.apply_ui_theme_requested.emit()
	EventBus.save_data_requested.emit()
	
	# Re-open appearance menu with new applied theme
	SceneManager.reload_current_scene_requested.emit("Appearance")
