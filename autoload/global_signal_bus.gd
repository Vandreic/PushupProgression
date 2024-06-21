## Manages global signals used across the app. Loaded using autoload.
##
## Manages global signals used across the app working like a centrailized reposetory
## storing all the signals used troughout the app. This is to make the code more
## scalable and make sure scripts can function independently of other scripts. [br]
##
## [br]
##
## This script is autoloaded and can be called from everywhere in the code using:
## [code]GlobalSignalBus[/code]


extends Node


## Signal to createa a notification. [br]
##
## [br]
##
## Parameters: [br]
## • [param notification_text] ([String]): Text to display in the notification. [br]
## • [param extend_duration] ([bool]): If [code]true[/code], doubles the display duration.
## Default: [code]false[/code] [br]
##
## [br]
##
## See [member NotificationSystem.create_notification] for more details.
signal create_notification(notification_text: String, extend_duration: bool)

## Signal to add a log entry to [member logs_array] [br]
##
## [br]
##
## Parameters: [br]
## • [param message] ([String]): Text for log message. [br]
##
## [br]
##
## See [member Data.add_log_entry] for more details.
signal add_log_entry(message: String)


signal update_ui

signal apply_ui_theme

signal load_data
