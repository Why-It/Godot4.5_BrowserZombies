extends Node

var selected_map = null

# Called when the node enters the scene tree for the first time.
func _ready():
	switch_selected_map(0)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false


func _on_quit_pressed():
	quit()

func quit():
	get_tree().quit()


func _on_map_selector_item_selected(index):
	print(index)
	switch_selected_map(index)

func switch_selected_map(index):
	if index == 0:
		selected_map = "res://scenes_levels/sen_dolta.tscn"
	elif index == 1:
		selected_map = "res://scenes_levels/test_scene.tscn"
	
	print(selected_map)


func _on_start_pressed():
	get_node("/root/global").goto_scene(selected_map)
