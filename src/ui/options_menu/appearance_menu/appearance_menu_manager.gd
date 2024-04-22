## Appearance Menu Manager.
## 
## Controls the behavior of appearance menu. [br]
##
## [br]
##
## Path: [code]res://src/ui/options_menu/appearance_menu/appearance_menu_manager.gd[/code]


class_name AppearanceMenuManager
extends CanvasLayer


## Themes option button.
@onready var themes_option_button: OptionButton = %ThemesOptionButton

## Close menu button.
@onready var close_menu_button: Button = %CloseMenuButton


## Create theme options.
func create_theme_options() -> void:
	# Create theme option for every theme
	for theme in GlobalVariables.ui_themes_dict:
		# Define theme name
		var theme_name: String = "  " + theme.capitalize() + "  "
		# Add theme to option button
		themes_option_button.add_item(theme_name)
	
	# Select chosen theme
	themes_option_button.select(GlobalVariables.selected_theme_index)


## Close appearance menu (Removes scene from tree).
func close_menu() -> void:
	# Delete scene from tree
	get_parent().remove_child(self)
	queue_free()


## On [member AppearanceMenuManager.close_menu_button] pressed.
func _on_close_menu_button_pressed() -> void:
	# Close appearance menu
	close_menu()


## On [member AppearanceMenuManager.themes_option_button] select. [br][br]
## Used when a theme is selected. 
func _on_themes_option_button_select(index) -> void:
	# Update selected theme index
	GlobalVariables.selected_theme_index = index
	
	# Loop trough themes
	for theme in GlobalVariables.ui_themes_dict:
		# Define theme name
		var theme_name: String = "  " + theme.capitalize() + "  "
		# Get chosen theme
		if themes_option_button.get_item_text(index) == theme_name:
			# Update theme
			GlobalVariables.chosen_ui_theme = GlobalVariables.ui_themes_dict[theme]["theme"]
	
	# Apply theme
	GlobalVariables.apply_ui_theme()
	# Save data
	GlobalVariables.save_data()
	# Re-open menu with selected theme
	get_tree().call_group("options_menu_button_manager", "open_appearance_menu")
	# Close current menu 
	close_menu()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signals
	close_menu_button.pressed.connect(close_menu)
	themes_option_button.item_selected.connect(_on_themes_option_button_select)
	# Create theme options
	create_theme_options()
