extends CharacterBody3D

## NOTES
## Need to remove collision so the player doesn't run into the corpse
## Need to change collider layers s othe player isn't shooting the zombie's navigation capsule, but only the skeleton colliders
## Need to add states and logic to make the zombie
## - spawn
## - go to closest barricade
## - tear barricade down
## - then target player
## 


var player = null
@export var player_path : NodePath

##State Machine Shit
var state_machine

var move_speed = 1.5
var health = 100
var limb_damage_modifier = 1
var head_damage_modifier = 2

var attack_damage = 20
var attack_distance = 1.5

@onready var nav_agent = $NavigationAgent3D

@onready var anim = $AnimationPlayer
@onready var anime_tree = $AnimationTree
@onready var collision_shape = $CollisionShape3D

func _ready():
	player = get_node(player_path)
	state_machine = anime_tree.get("parameters/playback")
	anime_tree.set("active", true)
	pass

func _process(_delta):
	
	if health <= 0:
		death()

var previous_state = null
func _physics_process(delta: float) -> void:
	match state_machine.get_current_node():
		"Idle":
			anime_tree.set("parameters/conditions/Walk", true)
		"Walk":
			velocity = Vector3.ZERO
			
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * move_speed
			look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z), Vector3.UP)
			anime_tree.set("parameters/conditions/Attack", target_in_range())
			
			move_and_slide()
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			anime_tree.set("parameters/conditions/Walk", !target_in_range())
			pass
		"Hit":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			anime_tree.set("parameters/conditions/Hit", false)
			if previous_state == "Attack" or "Walk":
				anime_tree.set("parameters/conditions/Walk", true)
			elif previous_state == "Idle":
				anime_tree.set("parameters/conditions/Idle", true)
			pass
		"Death":
			anime_tree.set("parameters/conditions/Death", false)
			pass
		"Spawning":
			pass
	
	if is_sinking:
		global_position = lerp(global_position,Vector3(global_position.x,global_position.y - 1,global_position.z),0.0025)

func target_in_range():
	return global_position.distance_to(player.global_position) < attack_distance

func hit(damage):
	health -= damage
	if health <= 0.0:
		anime_tree.set("parameters/conditions/Death", true)
		has_died = true
	else:
		print("hit")
		previous_state = state_machine.get_current_node()
		anime_tree.set("parameters/conditions/Hit", true)
	pass

func hit_player():
	if target_in_range():
		var dir = global_position.direction_to(player.global_position)
		player.take_damage(attack_damage, dir)
		pass
	pass

@onready var despawn_delay_timer = $DespawnDelay
@onready var sink_delay_timer = $SinkDelay
var has_died = false
func death():
	if has_died:
		despawn_delay_timer.start()
		sink_delay_timer.start()
		has_died = false
	pass


func _on_despawn_delay_timeout() -> void:
	print("despawning")
	queue_free()
	pass # Replace with function body.

var is_sinking = false
func _on_sink_delay_timeout() -> void:
	print("Sinking")
	is_sinking = true
	pass # Replace with function body.
