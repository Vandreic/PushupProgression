## Option Menu Component Script.
##
## Base script for components with-in options menu.
## 
## Path: [code]res://src/ui/options_menu/base_option_menu.gd[/code]


class_name OptionMenuComponent
extends CanvasLayer


## Apply UI theme to background panel.
func apply_current_ui_theme(background_panel: Panel) -> void:
	# Apply current theme
	background_panel.theme = GlobalVariables.current_ui_theme
	# Create stylebox variant
	var new_stylebox: StyleBoxFlat = GlobalVariables.create_custom_panel_stylebox()
	# Override panel theme stylebox
	background_panel.add_theme_stylebox_override("panel", new_stylebox)


## Close menu (Removes scene from tree).
func close_menu(menu_scene: CanvasLayer) -> void:
	# Delete scene from tree
	get_parent().remove_child(menu_scene)
	queue_free()
	
