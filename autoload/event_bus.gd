## Manages global signals used across the app.
##
## Manages global signals used across the app working like a centrailized reposetory
## storing all the signals used troughout the app.


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


signal ui_theme_changed


signal update_ui_requested

signal apply_ui_theme_requested

signal save_data_requested

signal load_data_requested

signal reset_data_requested(selected_reset_option: String)

signal pushups_added
