## Global Variables Singleton (Autoload).
##
## This singleton script serves as a central repository for storing and 
## accessing global variables used throughout the application. [br][br]
## 
## Path: [code]res://global/global_variables.gd[/code] [br]
##
## [br]
##
## Structure of [member save_data_dict]:
##
## [codeblock]
## save_data_dict
##
## > user settings
## >> daily pushups goal
## >> pushups per session
##
## > calendar
## >> year number
## >>> month number
## >>>> day number
## >>>>> daily pushups goal today
## >>>>> pushups per session today
## >>>>> remaining pushups today
## >>>>> sessions today
## >>>>>> session 1
## >>>>>>> pushups in session
## >>>>>>> time of session
## >>>>>> session 2
## >>>>>>> pushups in session
## >>>>>>> time of session
## >>>>> total pushups today
## [/codeblock]
##
## Example structure:
##
## [codeblock]
## save_data_dict: {
##     "settings": {
##         "daily_pushups_goal": 100,
##         "pushups_per_session": 10
##     },
##     "calendar": {
##         "2024": {
##             "03": {
##                 "24": {
##                     "daily_pushups_goal": 100,
##                     "pushups_per_session": 10,
##                     "remaining_pushups": 80,
##                     "sessions": {
##                         "session_1": {
##                             "pushups": 10,
##                             "time": "10:41:59"
##                         },
##                         "session_2": {
##                             "pushups": 10,
##                             "time": "12:36:08"
##                         },
##                     "total_pushups_today": 80
##                     }
##                 }
##             }
##         }
##     }
## }
## [/codeblock]



extends Node

## Main menu scene file path.
const MAIN_SCENE_PATH: String = "res://src/main/main.tscn"

## Logging menu scene file path.
const LOGGING_MENU_SCENE_PATH: String = "res://src/ui/options_menu/logging_menu/logging_menu.tscn"

## App running flag.
var app_running: bool = false


## Daily pushup goal.
var daily_pushups_goal: int = 100

## Number of pushups in each session.
var pushups_per_session: int = 10

## Total pushups today.
var total_pushups_today: int = 0

## Total pushups sessions today.
var total_pushups_sessions: int = 0

## Remaining pushups to reach daily goal.
var remaining_pushups: int = 0

## Save data [Dictionary] to store settings and progression data.
var save_data_dict: Dictionary = {
	# Stores user settings
	"settings": {
		"daily_pushups_goal": 0,
		"pushups_per_session": 0
	},
	# Stores data for each day
	"calendar": {}
}

## Stores log messages.
var logs_array: Array = []


## Create log message. [br]
##
## [br]
##
## See [method SaveSystem.create_log] for more details.
func create_log(log_message: String) -> void:
	# Create log
	get_tree().call_group("save_system", "create_log", log_message)


## Create notification. [br]
##
## [br]
##
## See [method NotificationSystem.create_notification] for more details.
func create_notification(notification_text: String, extended_duration: bool = false) -> void:
	# Create notification
	get_tree().call_group("notification_system", "create_notification", notification_text, extended_duration)


## Update UI. [br]
##
## [br]
##
## See [method UIManager.update_ui] for more details.
func update_ui() -> void:
	get_tree().call_group("ui_manager", "update_ui")


## Save data. [br]
##
## [br]
##
## See [method SaveSystem.save_data] for more details.
func save_data() -> void:
	get_tree().call_group("save_system", "save_data")


## Load data. [br]
##
## [br]
##
## See [method SaveSystem.load_data] for more details.
func load_data() -> void:
	get_tree().call_group("save_system", "load_data")
