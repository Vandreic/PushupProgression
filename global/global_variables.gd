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
##     "user_settings": {
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

## Constant: Main menu scene file path.
const MAIN_SCENE_PATH: String = "res://src/main/main.tscn"

## Constant: Logging menu scene file path.
const LOGGING_MENU_SCENE_PATH: String = "res://src/ui/options_menu/logging_menu/logging_menu.tscn"

## App running flag [bool].
var app_running: bool = false


## Daily pushup goal.
var daily_pushups_goal: int = 100

## Number of pushups in each session.
var pushups_per_session: int = 10

## Total pushups.
var total_pushups_today: int = 0

## Total pushups sessions.
var total_pushups_sessions: int = 0

## Remaining pushup to reach daily goal.
var remaining_pushups: int = 0

## Save data [Dictionary] to store all progression data.
var save_data_dict: Dictionary = {
	# Stores user settings
	"settings": {
		"daily_pushups_goal": 0,
		"pushups_per_session": 0
	},
	# Stores data for each day
	"calendar": {}
}

## Logs [Array].
var logs_array: Array = []
