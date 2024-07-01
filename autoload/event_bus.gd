extends Node


## Manages global signals used across the app. [br]
##
## [br]
##
## This autoloaded script stores and manages global signals, allowing different
## scripts to connect and emit these signals globally. [br]
##
## [br]
## 
## It is accessed globally as [code]EventBus[/code]. [br]
##
## [br]
##
## [b]Path:[/b] [code]res://autoload/event_bus.gd[/code]


## Signal to request creating a notification. [br]
##
## [br]
##
## Emitted when a notification needs to be created. [br]
##
## [br]
##
## Parameters: [br]
## • [param notification_text] ([String]): Text to display in the notification. [br]
## • [param extend_duration] ([bool]): If [code]true[/code], doubles the display duration. [br]
##
## [br]
##
## See [method NotificationSystem._on_create_notification_requested] for more details.
signal create_notification_requested(notification_text: String, extend_duration: bool)

## Signal to request applying UI theme based on [member Data.current_ui_theme]. [br]
##
## [br]
##
## Emitted when a UI theme needs to be applied. [br]
##
## [br]
##
## See [method UIManager._on_apply_ui_theme_requested] for more details.
signal apply_ui_theme_requested

## Signal to request updating the UI. [br]
##
## [br]
##
## Emitted when the UI needs to be updated. [br]
##
## [br]
##
## See [method UIManager._on_update_ui_requested] for more details.
signal update_ui_requested

## Signal to request saving data. [br]
##
## [br]
##
## Emitted when progression data and settings need to be saved. [br]
##
## [br]
##
## See [method SaveSystem._on_save_data_requested] for more details.
signal save_data_requested

## Signal to request loading data. [br]
##
## [br]
##
## Emitted when progression data and settings need to be loaded. [br]
##
## [br]
##
## See [method SaveSystem._on_load_data_requested] for more details.
signal load_data_requested

## Signal to request resetting data. [br]
##
## [br]
##
## Emitted when progression data needs to be reset. [br]
##
## [br]
##
## Parameters: [br]
## • [param selected_reset_option] ([String]): The selected option for data reset. [br]
##
## [br]
##
## See [method SaveSystem._on_reset_data_requested] for more details.
signal reset_data_requested(selected_reset_option: String)

## Signal to notify pushups added. [br]
##
## [br]
##
## Emitted when pushups are added to the count. [br]
##
## [br]
##
## See [method Data._on_pushups_added] for more details.
signal pushups_added
