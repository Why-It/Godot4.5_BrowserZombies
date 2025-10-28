extends Control

var is_confirmation_visible = false

@onready var round_counter = $BoxContainer/mid/mid/Panel/VBoxContainer2/center/center/Stats/Rounds/rounds_counter
@onready var kill_counter = $BoxContainer/mid/mid/Panel/VBoxContainer2/center/center/Stats/Kills/kills_counter
@onready var headshot_counter = $BoxContainer/mid/mid/Panel/VBoxContainer2/center/center/Stats/VBoxContainer3/headshot_counter
@onready var points_counter = $"BoxContainer/mid/mid/Panel/VBoxContainer2/center/center/Stats/Total Points2/points_counter"

func _ready():
	self.set("visible", false)

func _death():
	self.set("visible", true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#get_tree().paused = true

func _on_main_menu_pressed():
	# Open the confirmation panel
	get_node("/root/global").goto_scene("res://scenes_levels/mainmenu.tscn")
