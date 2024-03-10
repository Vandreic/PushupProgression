## UI Manager Script.
##
## [br]
##
## This script controls the behavior of UI elements. [br]
##
## [br]
## 
## Path: [code]res://src/ui/ui_manager.gd[/code]


class_name UIManager
extends Node


## Quote label.
@onready var quote_label: Label = %QuoteLabel

## Progression label.
@onready var progress_label: Label = %ProgressLabel

## Progress bar.
@onready var progress_bar: TextureProgressBar = %ProgressBar

## Progress value label.
@onready var progress_value_label: Label = %ProgressValueLabel

## Daily goal label.
@onready var daily_goal_label: Label = %DailyGoalLabel

## Remaining pushups label.
@onready var remaining_pushups_label: Label = %RemainingPushupsLabel

## Add pushups button.
@onready var add_pushups_button: Button = %AddPushupsButton

## Open options menu button.
@onready var options_menu_button: TextureButton = %OptionsMenuButton

## App versiob label.
@onready var app_version: Label = %AppVersion


## Open settings menu button.
func open_settings_menu() -> void:
	# Instantiate reset options menu scene
	var settings_menu: CanvasLayer = load("res://src/ui/options_menu/settings_menu/settings_menu.tscn").instantiate()
	# Add scene to tree (Needed before modifying)
	get_parent().add_child(settings_menu)


## Open reset options menu.
func open_reset_options_menu() -> void:
	# Instantiate reset options menu scene
	var options_menu: CanvasLayer = load("res://src/ui/options_menu/reset_options_menu/reset_options_menu.tscn").instantiate()
	# Add scene to tree (Needed before modifying)
	get_parent().add_child(options_menu)
	# Connect signals, passing a reset option
	options_menu.reset_current_day_button_pressed.connect(open_popup_confirm_box.bind("current_day"))
	#options_menu.reset_current_week_button_pressed.connect(open_popup_confirm_box.bind("current_week"))
	options_menu.reset_current_month_button_pressed.connect(open_popup_confirm_box.bind("current_month"))
	options_menu.reset_current_year_button_pressed.connect(open_popup_confirm_box.bind("current_year"))
	options_menu.reset_all_button_pressed.connect(open_popup_confirm_box.bind("all"))


## Open popup confirm box (Used for reset options menu).
func open_popup_confirm_box(reset_option: String) -> void:
	# Instantiate popup confirm box scene
	var popup_box: CanvasLayer = load("res://src/ui/popup_confirm_box/popup_confirm_box.tscn").instantiate()
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


## Reset progression. [br]
## See [member SaveSystem.reset_data] for more details.
func reset_progression(reset_option: String) -> void:
	# Reset data based of reset_option value
	get_tree().call_group("save_system", "reset_data", reset_option)
	# Update UI
	update_ui()


## Update progress bar.
func update_progress_bar() -> void:
	# Get total pushups today
	var total_pushups_today: float = float(GlobalVariables.total_pushups_today)
	# Get daily pushups goal
	var daily_pushups_goal: float = float(GlobalVariables.daily_pushups_goal)
	
	# Calculate new progress bar value
	var new_progress_bar_value: float = (total_pushups_today / daily_pushups_goal) * 100
	
	# Check if progress bar reached 100%
	if new_progress_bar_value >= 100:
		# Update progress bar value
		progress_bar.value = 100
		# Update progress value text
		progress_value_label.text = str(round(new_progress_bar_value)) + "%!"
	else:
		progress_bar.value = new_progress_bar_value
		progress_value_label.text = str(round(new_progress_bar_value)) + "%"


## Update progress text.
func update_progress_text() -> void:
	# Create progress text
	var progress_text: String = "Total pushups today: " + str(GlobalVariables.total_pushups_today)
	
	# Check if progress bar reached 100%
	if progress_bar.value >= 100:
		# Update progress text
		progress_label.text = "Goal reached! Keep pushing. \n" + progress_text
	else:
		progress_label.text = progress_text


## Update daily goal text.
func update_daily_goal_text() -> void:
	# Update daily goal
	daily_goal_label.text = "Daily goal: " + str(GlobalVariables.daily_pushups_goal)
	# Update remaining pushups to reach daily goal
	GlobalVariables.remaining_pushups = GlobalVariables.daily_pushups_goal - GlobalVariables.total_pushups_today
	# Update remaining pushups text
	remaining_pushups_label.text = "Remaining: " + str(GlobalVariables.remaining_pushups)
	
	# Check if progress bar reached 100%
	if progress_bar.value >= 100:
		# Update remaining pushups text
		remaining_pushups_label.text = "Remaining: 0"


## Update UI elements.
func update_ui() -> void:
	# Update progress bar
	update_progress_bar()
	# Update progress text
	update_progress_text()
	# Update daily goal text
	update_daily_goal_text()
	
	# Update "add pushups" button text
	add_pushups_button.text = "Add " + str(GlobalVariables.pushups_per_session) + " pushups"


## On [member UIManager.add_pushups_button] pressed.
func _on_add_pushups_button_pressed() -> void:
	# Update total pushups today
	GlobalVariables.total_pushups_today += GlobalVariables.pushups_per_session
	# Update remaining pushups
	GlobalVariables.remaining_pushups -= GlobalVariables.pushups_per_session
	
	# Update remaining pushups to 0 if <= 0
	if GlobalVariables.remaining_pushups <= 0:
		GlobalVariables.remaining_pushups = 0

	# Update total sessions
	GlobalVariables.total_pushups_sessions += 1
	
	# Save data
	get_tree().call_group("save_system", "save_data")
	# Update UI
	update_ui()


## On [member UIManager.options_menu_button] pressed.
func _on_options_menu_button_pressed() -> void:
	# Instantiate options menu scene
	var options_menu: CanvasLayer = load("res://src/ui/options_menu/options_menu.tscn").instantiate()
	# Add scene to tree (Needed before modifying)
	get_parent().add_child(options_menu)
	# Connect to custom pressed button signals
	options_menu.settings_button_pressed.connect(open_settings_menu)
	options_menu.reset_menu_button_pressed.connect(open_reset_options_menu)


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set app version label
	app_version.text = "version " + str(ProjectSettings.get_setting("application/config/version"))
	# Connect pressed button signals
	add_pushups_button.pressed.connect(_on_add_pushups_button_pressed)
	options_menu_button.pressed.connect(_on_options_menu_button_pressed)
