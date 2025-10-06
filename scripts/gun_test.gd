extends Node3D

var damage = 10
var automatic = false
var fire_rate = 1

@onready var anim_player = $gun_test/AnimationPlayer
@onready var bhole_decal = preload("res://blueprints_prefabs/bullet_hole_placeholder.tscn")

func _ready():
	pass
