extends Node3D

@export var planks = []
var is_plank00_down = false
var is_plank01_down = false
var is_plank02_down = false
@onready var anim_player = $AnimationPlayer
var is_player_within_range = false
var is_zombie_within_range = false
@onready var zombie_tele_target = $ZombieTeleportTarget
@export var player = Node

func _ready() -> void:
	
	pass

func remove_plank():
	if !anim_player.is_playing():
		if !is_plank00_down:
			anim_player.play("Plank00_Trigger")
			is_plank00_down = true
		elif  is_plank00_down && !is_plank01_down:
			anim_player.play("Plank01_Trigger")
			is_plank01_down = true
		elif  is_plank00_down && is_plank01_down && !is_plank02_down:
			anim_player.play("Plank02_Trigger")
			is_plank02_down = true

func rebuild_plank():
	if !anim_player.is_playing():
		if is_plank02_down:
			anim_player.play_backwards("Plank02_Trigger")
			is_plank02_down = false
			player.add_points(20)
		elif !is_plank02_down && is_plank01_down:
			anim_player.play_backwards("Plank01_Trigger")
			is_plank01_down = false
			player.add_points(20)
		elif !is_plank02_down && !is_plank01_down && is_plank00_down:
			anim_player.play_backwards("Plank00_Trigger")
			is_plank00_down = false
			player.add_points(20)


func _on_interaction_range_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		is_player_within_range = true
		body.able_to_interact = true
		body.interact_object = $"."


func _on_interaction_range_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		is_player_within_range = false
		body.able_to_interact = false
		body.interact_object = null


var enemy = null
func _on_zombie_interaction_range_body_entered(body: Node3D) -> void:
	enemy = find_enemy_root(body)
	if !is_zombie_within_range:
		if enemy != null:
			is_zombie_within_range = true
			if enemy.is_barricade_targeted == false:
				enemy.target_barricade(self)

func _on_zombie_interaction_range_body_exited(body: Node3D) -> void:
	enemy = find_enemy_root(body)
	if enemy != null:
		is_zombie_within_range = false

func find_enemy_root(node):
	while node != null:
		if node.is_in_group("enemy"):
			return node
		node = node.get_parent()
	return null

func set_anim_speed(speed: float):
	anim_player.speed_scale = speed

func set_plank_collision(plank: Node, status: bool):
	plank.set("use_collision", status)
