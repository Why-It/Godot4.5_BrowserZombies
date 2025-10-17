extends Node3D

@export var player = Node3D

@export var barricades = []

@export var spawners_location_in_tree : Node3D
var zombie_spawners = []
@export var zombie_check_timer : Node

@export var zombie_location_in_tree : Node3D
var zombies_in_play = []

var cur_round : int
var cur_difficulty : float

func _ready() -> void:
	zombie_spawners = spawners_location_in_tree.get_children()

func zombie_check():
	zombies_in_play = zombie_location_in_tree.get_children()
	
	if zombies_in_play.size() < 9:
		spawn_zombie()

func change_difficulty():
	## The plan here to is use the current round to affect the speed and damage zombies do.
	## Take the current level integer, use maths, modify the spawning logic of the instatiated zombie to modify their attrivutes upon spawning
	## Difficulty should probably be assigned within this game manager script, leavin the zombie prefab as a base/default character
	## Also change the maximum amount of zombies to spawn in the round
	## Also change the types of zombies to be spawned
	
	#cur_difficulty = cur_difficulty + (cur_round/10)
	pass

func spawn_zombie():
	closest_spawner_to_player()
	closest_spawner.spawn_zombie()

var closest_spawner = null
func closest_spawner_to_player():
	closest_spawner = zombie_spawners[0]
	for spawner_index in range(0, zombie_spawners.size()):
		zombie_spawners[spawner_index].spawner_distance_to_player = zombie_spawners[spawner_index].position.distance_squared_to(player.position)
		if zombie_spawners[spawner_index].spawner_distance_to_player < closest_spawner.spawner_distance_to_player:
			closest_spawner = zombie_spawners[spawner_index]
	
	print("closest spawner = ", closest_spawner)
	return closest_spawner

func _on_zombie_check_timer_timeout() -> void:
	zombie_check()
	zombie_check_timer.start()
