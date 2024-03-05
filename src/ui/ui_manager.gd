## UI Manager.
##
## [br]
##
## Manages UI element updates. [br]
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

## Button: Add pushups.
@onready var add_pushups_button: Button = %AddPushupsButton

## Button: Reset progression.
@onready var reset_progression_button: Button = %ResetProgressionButton

## App versiob label.
@onready var app_version: Label = %AppVersion


## On [member UIManager.add_pushups_button] pressed.
func _on_add_pushups_button_pressed() -> void:
	# Update total pushups today
	GlobalVariables.total_pushups_today += GlobalVariables.pushups_per_session
	# Update remaining pushups
	GlobalVariables.remaining_pushups -= GlobalVariables.pushups_per_session
	
	# Check if remaining pushups 0
	if GlobalVariables.remaining_pushups <= 0:
		# Update remaining pushups to 0
		GlobalVariables.remaining_pushups = 0

	# Update total sessions
	GlobalVariables.total_pushups_sessions += 1
	
	# Save progression
	get_tree().call_group("save_system", "save_data")
	# Update UI
	update_ui()


## On [member UIManager.reset_progression_button] pressed.
func _on_reset_progression_button() -> void:
	# Check if any sessions
	if GlobalVariables.total_pushups_sessions > 0:
		# Reset progression data
		get_tree().call_group("save_system", "reset_date")
		# Update UI
		update_ui()
	else:
		print("Error: No progress to reset.")


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
		progress_value_label.text = str(new_progress_bar_value) + "%!"
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
	
	# Disable "reset progression" button if no sessions
	if GlobalVariables.total_pushups_sessions <= 0:
		reset_progression_button.disabled = true
	else:
		reset_progression_button.disabled = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set app version label
	app_version.text = "version " + str(ProjectSettings.get_setting("application/config/version"))
	
	# Connect pressed button signals
	add_pushups_button.pressed.connect(_on_add_pushups_button_pressed)
	reset_progression_button.pressed.connect(_on_reset_progression_button)
