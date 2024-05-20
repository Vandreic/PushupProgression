## Manages UI updates for the Current Progress Container.
##
## Updates and manages all user interface elements related to the 
## [code]CurrentProgressContainer[/code], including progress bars, labels, and
## buttons. It ensures all elements reflect the latest data and theme changes. [br]
##
## [br]
##
## Usage: [br]
## • [method update_ui]: Updates all UI elements within the container. [br]
## • [method apply_ui_theme]: Applies the current UI theme to UI elements. [br]
##
## [br]
##
## Path: [code]res://scenes/ui/current_progress_container_manager.gd[/code]

class_name CurrentProgressContainerManager
extends VBoxContainer


## Displays total push-ups completed today.
@onready var progress_label: Label = %ProgressLabel

## Visual progress bar towards daily goal.
@onready var progress_bar: TextureProgressBar = %ProgressBar

## Shows progress as a percentage.
@onready var progress_value_label: Label = %ProgressValueLabel

## Indicates the daily goal for push-ups.
@onready var daily_goal_label: Label = %DailyGoalLabel

## Shows remaining push-ups needed to meet the daily goal.
@onready var pushups_remaining_today_label: Label = %RemainingPushupsLabel

## Button to log additional push-ups.
@onready var add_pushups_button: Button = %AddPushupsButton


## Sets up button connection when the node is ready.
func _ready() -> void:
	add_pushups_button.pressed.connect(_on_add_pushups_button_pressed)


## Applies the current UI theme to the progress bar based on [member GlobalVariables.current_ui_theme].
func apply_ui_theme() -> void:
	for theme in GlobalVariables.available_themes:
		if GlobalVariables.current_ui_theme.get_instance_id() == GlobalVariables.available_themes[theme]["instance_id"]:
			progress_bar.texture_under = GlobalVariables.available_themes[theme]["progress_bar"]["under"]
			progress_bar.texture_over = GlobalVariables.available_themes[theme]["progress_bar"]["over"]
			progress_bar.texture_progress = GlobalVariables.available_themes[theme]["progress_bar"]["progress"]


## Updates all UI elements within the container.
func update_ui() -> void:
	_update_progress_bar()
	_update_total_pushups_text()
	_update_daily_goal_and_pushups_remaining_text()
	_update_add_pushups_button_text()
	apply_ui_theme()


## Updates the progress bar and its value label.
func _update_progress_bar() -> void:
	var new_progress_bar_value = GlobalVariables.total_pushups_today * 100 / GlobalVariables.daily_pushups_goal
	progress_bar.value = new_progress_bar_value
	progress_value_label.text = str(new_progress_bar_value) + "%"

	# Update text if 100% is reached
	if new_progress_bar_value >= 100:
		progress_value_label.text = str(new_progress_bar_value) + "%!"


## Updates the label for total push-ups completed today.
func _update_total_pushups_text() -> void:
	var progress_text = "Total push-ups today: " + str(GlobalVariables.total_pushups_today)
	progress_label.text = progress_text

	# Update text if daily goal is reached
	if progress_bar.value >= 100:
		progress_label.text = "Goal reached! Keep pushing.\n" + progress_text


## Updates labels for daily goal and remaining push-ups.
func _update_daily_goal_and_pushups_remaining_text() -> void:
	GlobalVariables.pushups_remaining_today = GlobalVariables.daily_pushups_goal - GlobalVariables.total_pushups_today
	daily_goal_label.text = "Daily goal: " + str(GlobalVariables.daily_pushups_goal)
	pushups_remaining_today_label.text = "Remaining: " + str(GlobalVariables.pushups_remaining_today)

	# Update text if daily goal is reached
	if progress_bar.value >= 100:
		pushups_remaining_today_label.text = "Remaining: 0"


## Updates the text on the [member add_pushups_button].
func _update_add_pushups_button_text() -> void:
	add_pushups_button.text = "Add " + str(GlobalVariables.pushups_per_session) + " push-ups"


## Signal handler for when the [member add_pushups_button] is pressed. [br]
##
## [br]
##
## Adds push-ups and updates the UI.
func _on_add_pushups_button_pressed() -> void:
	GlobalVariables.total_pushups_today += GlobalVariables.pushups_per_session
	GlobalVariables.pushups_remaining_today -= GlobalVariables.pushups_per_session

	# Set remaining push-ups to 0 if daily goal is reached
	if GlobalVariables.pushups_remaining_today <= 0:
		GlobalVariables.pushups_remaining_today = 0

	GlobalVariables.sessions_completed_today += 1
	GlobalVariables.add_log_entry("Added new push-up session.")
	GlobalVariables.save_data()
	GlobalVariables.update_ui()
	
