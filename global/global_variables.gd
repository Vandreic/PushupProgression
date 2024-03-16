## Global Variables Singleton (Autoload).
##
## This singleton script serves as a central repository for storing and 
## accessing global variables used throughout the application. [br]
## 
## Path: [code]res://global/global_variables.gd[/code]


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
var save_data_dict: Dictionary = {}

## Logs [Array].
var logs_array: Array = []
