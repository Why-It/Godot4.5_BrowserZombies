extends Control

var is_visible = false
var is_confirmation_visible = false

func _ready():
	$".".set("visible", is_visible)

func _pause():
	$".".set("visible", true)
	is_visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	get_tree().paused = true

func _on_resume_pressed():
	get_tree().paused = false
	
	$".".set("visible", false)
	is_visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_settings_pressed():
	# Disable the visibility of the pause menu, enable the visibikity of the settings menu
	pass


func _on_main_menu_pressed():
	# Open the confirmation panel
	$BoxContainer/mid/mid/Panel/confirmation_panel.set("visible", true)
	is_confirmation_visible = true


func _on_cancel_pressed():
	# Hide the confirmation panel
	$BoxContainer/mid/mid/Panel/confirmation_panel.set("visible", false)
	is_confirmation_visible = false

func _on_confirm_pressed():
	get_node("/root/global").goto_scene("res://scenes_levels/mainmenu.tscn")
