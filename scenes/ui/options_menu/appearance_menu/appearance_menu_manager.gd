## Appearance Menu Manager.
## 
## Controls the behavior of appearance menu. [br]
##
## [br]
##
## Path: [code]res://src/ui/options_menu/appearance_menu/appearance_menu_manager.gd[/code]


class_name AppearanceMenuManager
extends OptionMenuComponent


## Background panel.
@onready var background_panel: Panel = %BackgroundPanel

## Themes option button.
@onready var themes_option_button: OptionButton = %ThemesOptionButton

## Close menu button.
@onready var close_menu_button: Button = %CloseMenuButton


## Create theme options.
func create_theme_options() -> void:
	# Create theme option for every theme
	for theme in GlobalVariables.available_themes:
		# Define theme name
		var theme_name: String = "  " + theme.capitalize() + "  "
		# Add theme to option button
		themes_option_button.add_item(theme_name)
	
	# Select chosen theme
	themes_option_button.select(GlobalVariables.selected_theme_index)


## Re-open appearance menu with new applied theme.
func reopen_menu() -> void:
	# Define new current scene name
	var _name: String = "Deleted" + self.name
	# Change current scene name
	self.name = _name
	# Hide current scene
	self.visible = false
	
	# Instantiate new appearance menu scene
	var new_menu: CanvasLayer = load("res://src/ui/options_menu/appearance_menu/appearance_menu.tscn").instantiate()	
	# Apply theme to new appearance menu
	new_menu.get_node("%BackgroundPanel").theme = GlobalVariables.current_ui_theme
	# Add appearance menu scene to tree
	get_parent().add_child(new_menu)
	
	# Close current appearance menu
	close_menu(self)


## On [member AppearanceMenuManager.close_menu_button] pressed.
func _on_close_menu_button_pressed() -> void:
	# Close appearance menu
	close_menu(self)


## On [member AppearanceMenuManager.themes_option_button] select. [br][br]
## Used when a theme is selected. 
func _on_themes_option_button_select(index) -> void:
	# Update selected theme index
	GlobalVariables.selected_theme_index = index
	
	# Loop trough themes
	for theme in GlobalVariables.available_themes:
		# Define theme name
		var theme_name: String = "  " + theme.capitalize() + "  "
		# Get chosen theme
		if themes_option_button.get_item_text(index) == theme_name:
			# Update theme
			GlobalVariables.current_ui_theme = GlobalVariables.available_themes[theme]["theme"]
	
	# Apply theme to UI scene and log change
	GlobalVariables.apply_current_ui_theme(true)
	# Save data
	GlobalVariables.save_data()
	
	# Open new appearance menu (Needed to update theme in menu)
	get_tree().call_group("options_menu_manager", "_on_appearance_button_pressed")
	# Re-open appearance menu with new applied theme
	reopen_menu()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	close_menu_button.pressed.connect(_on_close_menu_button_pressed)
	themes_option_button.item_selected.connect(_on_themes_option_button_select)
	# Create theme options
	create_theme_options()
	# Apply UI theme
	apply_current_ui_theme(background_panel)
