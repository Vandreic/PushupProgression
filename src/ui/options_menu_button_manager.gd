## Options Menu Button Manager.
##
## [br]
##
## Controls the behavior of options menu. [br]
##
## [br]
## 
## Path: [code]res://src/ui/options_menu_button_manager.gd[/code]


class_name OptionsMenuButtonManager
extends TextureButton


## Reset progression. [br]
## See [member SaveSystem.reset_data] for more details.
func reset_progression(reset_option: String) -> void:
	# Reset data based of reset_option value
	get_tree().call_group("save_system", "reset_data", reset_option)
	# Update UI
	GlobalVariables.update_ui()


## Open settings menu button.
func open_settings_menu() -> void:
	# Instantiate reset options menu scene
	var settings_menu: CanvasLayer = load("res://src/ui/options_menu/settings_menu/settings_menu.tscn").instantiate()	
	# Apply chosen UI theme
	settings_menu.get_node("%BackgroundPanel").theme = GlobalVariables.chosen_ui_theme
	# Add scene to tree (Needed before modifying)
	get_parent().add_child(settings_menu)


## Open reset options menu.
func open_reset_options_menu() -> void:
	# Instantiate reset options menu scene
	var options_menu: CanvasLayer = load("res://src/ui/options_menu/reset_options_menu/reset_options_menu.tscn").instantiate()
	# Apply chosen UI theme
	options_menu.get_node("%BackgroundPanel").theme = GlobalVariables.chosen_ui_theme
	# Add scene to tree (Needed before modifying)
	get_parent().add_child(options_menu)
	# Connect signals, passing a reset option
	options_menu.reset_current_day_button_pressed.connect(open_popup_confirm_box.bind("current_day"))
	options_menu.reset_current_month_button_pressed.connect(open_popup_confirm_box.bind("current_month"))
	options_menu.reset_current_year_button_pressed.connect(open_popup_confirm_box.bind("current_year"))
	options_menu.reset_all_button_pressed.connect(open_popup_confirm_box.bind("all"))


## Open popup confirm box (Used for reset options menu).
func open_popup_confirm_box(reset_option: String) -> void:
	# Instantiate popup confirm box scene
	var popup_box: CanvasLayer = load("res://src/ui/popup_confirm_box/popup_confirm_box.tscn").instantiate()
	# Apply chosen UI theme
	popup_box.get_node("%BackgroundPanel").theme = GlobalVariables.chosen_ui_theme
	# Add scene to tree (Needed before modifying)
	get_parent().add_child(popup_box)
	
	# Create info text
	var info_text: String
	# Modify info text
	if reset_option == "all":
		info_text = "Resetting all data will permanently delete all saved progression and cannot be undone."
	else:
		info_text = "Resetting %s will permanently delete all associated data and cannot be undone."\
		% reset_option.capitalize().to_lower()
	# Update popup box info text
	popup_box.update_info_text(info_text)
	
	# Connect signal, passing chosen reset option
	popup_box.confirm_button_pressed.connect(reset_progression.bind(reset_option))


## Open logging menu (Changes scene).
func open_logging_menu() -> void:
	# Change to logging menu scene
	get_tree().change_scene_to_file(GlobalVariables.LOGGING_MENU_SCENE_PATH)


## On options menu button pressed.
func _on_options_menu_button_pressed() -> void:
	# Instantiate options menu scene
	var options_menu: CanvasLayer = load("res://src/ui/options_menu/options_menu.tscn").instantiate()
	# Apply chosen UI theme
	options_menu.get_node("%BackgroundPanel").theme = GlobalVariables.chosen_ui_theme
	# Add scene to tree (Needed before modifying)
	get_parent().add_child(options_menu)
	# Connect to custom pressed button signals
	options_menu.settings_button_pressed.connect(open_settings_menu)
	options_menu.reset_menu_button_pressed.connect(open_reset_options_menu)
	options_menu.logging_menu_button_pressed.connect(open_logging_menu)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signal
	self.pressed.connect(_on_options_menu_button_pressed)
