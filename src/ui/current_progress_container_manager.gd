## Current Progress Container Manager.
##
## [br]
##
## Controls the behavior UI elements within the current progress container. [br]
##
## [br]
## 
## Path: [code]res://src/ui/current_progress_container_manager.gd[/code]


class_name CurrentProgressContainerManager
extends VBoxContainer


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


## Update total pushups text
func update_total_pushups_text() -> void:
	# Create progress text
	var progress_text: String = "Total pushups today: " + str(GlobalVariables.total_pushups_today)
	
	# Check if progress bar reached 100%
	if progress_bar.value >= 100:
		# Update progress text
		progress_label.text = "Goal reached! Keep pushing. \n" + progress_text
	else:
		progress_label.text = progress_text


## Update daily goal and remaining pushups text.
func update_daily_goal_and_remaining_pushups_text() -> void:
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


## Update "add pushups" button text.
func update_add_pushups_button_text() -> void:
	# Update "add pushups" button text
	add_pushups_button.text = "Add " + str(GlobalVariables.pushups_per_session) + " pushups"


## Update UI elements.
func update_ui() -> void:
	# Update progress bar
	update_progress_bar()
	# Update total pushups text
	update_total_pushups_text()
	# Update daily goal and remaining pushups text
	update_daily_goal_and_remaining_pushups_text()
	# Update "add pushups" button text
	update_add_pushups_button_text()


## On [member CurrentProgressContainerManager.add_pushups_button] pressed.
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
	# Create log message
	GlobalVariables.create_log("Added new pushup session.")
	# Save data
	GlobalVariables.save_data()
	# Update UI
	GlobalVariables.update_ui()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect pressed button signal
	add_pushups_button.pressed.connect(_on_add_pushups_button_pressed)
