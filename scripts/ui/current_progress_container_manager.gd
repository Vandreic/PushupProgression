class_name CurrentProgressContainerManager
extends VBoxContainer


## Manages UI updates for the [code]CurrentProgressContainer[/code].
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
## Path: [code]res://scripts/ui/current_progress_container_manager.gd[/code]



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


## Setup button connection when the node is ready.
func _ready() -> void:
	add_pushups_button.pressed.connect(_on_add_pushups_button_pressed)


## Applies the UI theme based on [member GlobalVariables.current_ui_theme].
func apply_ui_theme() -> void:
	var theme_name: String = Data.get_theme_name(Data.current_ui_theme)
	if Data.available_themes.has(theme_name):
		progress_bar.texture_under = Data.available_themes[theme_name]["progress_bar"]["under"]
		progress_bar.texture_over = Data.available_themes[theme_name]["progress_bar"]["over"]
		progress_bar.texture_progress = Data.available_themes[theme_name]["progress_bar"]["progress"]
		

## Update all UI elements within the container.
func update_ui() -> void:
	_update_progress_bar()
	_update_total_pushups_text()
	_update_daily_goal_and_pushups_remaining_text()
	_update_add_pushups_button_text()
	apply_ui_theme()


## Update the progress bar and its value label.
func _update_progress_bar() -> void:
	var new_progress_bar_value = Data.total_pushups_today * 100.0 / Data.daily_pushups_goal
	progress_bar.value = new_progress_bar_value
	progress_value_label.text = str(new_progress_bar_value) + "%"

	# Update text if 100% is reached
	if new_progress_bar_value >= 100:
		progress_value_label.text = str(new_progress_bar_value) + "%!"


## Update the label for total push-ups completed today.
func _update_total_pushups_text() -> void:
	var progress_text = "Total push-ups today: " + str(Data.total_pushups_today)
	progress_label.text = progress_text

	# Update text if daily goal is reached
	if progress_bar.value >= 100:
		progress_label.text = "Goal reached! Keep pushing.\n" + progress_text


## Updates labels for daily goal and remaining push-ups.
func _update_daily_goal_and_pushups_remaining_text() -> void:
	daily_goal_label.text = "Daily goal: " + str(Data.daily_pushups_goal)
	pushups_remaining_today_label.text = "Remaining: " + str(Data.pushups_remaining_today)

	# Update text if daily goal is reached
	if progress_bar.value >= 100:
		pushups_remaining_today_label.text = "Remaining: 0"


## Updates the text on the [member add_pushups_button].
func _update_add_pushups_button_text() -> void:
	add_pushups_button.text = "Add " + str(Data.pushups_per_session) + " push-ups"


## Signal handler for when the [member add_pushups_button] is pressed. [br]
##
## [br]
##
## Adds push-ups, saves data, and updates the UI.
func _on_add_pushups_button_pressed() -> void:
	Data.add_log_entry("Added new push-up session.")
	EventBus.pushups_added.emit()
	EventBus.save_data_requested.emit()
	EventBus.update_ui_requested.emit()
	
