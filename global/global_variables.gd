## Global Variables Singleton (Autoload).
##
## This singleton script serves as a central repository for storing and 
## accessing global variables used throughout the application. [br]
## 
## Path: [code]res://global/global_variables.gd[/code]


extends Node


## Daily pushup goal.
var daily_pushups_goal: int = 100

## Remaining pushup to reach daily goal.
var remaining_pushups: int = 0

## Number of pushups in each session.
var pushups_per_session: int = 10

## Total pushups sessions.
var total_pushups_sessions: int = 0

## Total pushups.
var total_pushups_today: int = 0

## Save data dictionary to store all progression data.
var save_data_dict: Dictionary = {}
