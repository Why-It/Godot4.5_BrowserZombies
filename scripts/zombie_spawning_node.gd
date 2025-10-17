extends Node3D

@export var zombie_scene : PackedScene
@onready var spawn_cooldown_timer = $SpawnCooldown
@onready var spawn_area = $SpawnRef/Area3D/CollisionShape3D
@onready var spawn_ref_point = null
var local_spawn_location : Vector3
var global_spawn_location : Vector3
@export var spawn_location_in_tree : Node3D

var game_manager = "/root"

var spawner_distance_to_player = null

func _ready() -> void:
	pass

func spawn_zombie():
	#spawn_cooldown_timer.start()
	setting_spawn_location()
	var zombie = zombie_scene.instantiate()
	zombie.global_transform.origin = global_spawn_location
	spawn_location_in_tree.add_child(zombie)

func setting_spawn_location():
	var spawn_sphere = spawn_area.shape
	var random_x = randf_range(spawn_sphere.radius, -spawn_sphere.radius)
	var random_z = randf_range(spawn_sphere.radius, -spawn_sphere.radius)
	local_spawn_location = Vector3(random_x, 0, random_z)
	global_spawn_location = spawn_area.global_position + local_spawn_location
	return global_spawn_location

func _on_spawn_cooldown_timeout() -> void:
	#setting_spawn_location()
	#var zombie = zombie_scene.instantiate()
	#zombie.global_transform.origin = global_spawn_location
	#spawn_location_in_tree.add_child(zombie)
	pass
