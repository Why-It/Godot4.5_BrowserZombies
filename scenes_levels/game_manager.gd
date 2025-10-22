extends Node3D

@export var player = Node3D

var zones = []
@export var zones_location_in_tree : Node3D
var cur_zone = null

@export var spawners_location_in_tree : Node3D
var zombie_spawners = []
@export var zombie_check_timer : Node

@export var zombie_location_in_tree : Node3D
var zombies_in_play = []

var cur_round : int
var cur_difficulty : float
@onready var tally_texture = preload("res://textures/T_Tally.png")
@onready var tally_strike_texture = preload("res://textures/T_TallyStrike.png")

func _ready() -> void:
	zones = zones_location_in_tree.get_children()
	zombie_spawners = spawners_location_in_tree.get_children()
	cur_round = 0
	increase_round()

func _input(event: InputEvent) -> void:
	if event.is_action_released("debug_increase_round"):
		increase_round()

func zombie_check():
	zombies_in_play = zombie_location_in_tree.get_children()
	
	if zombies_in_play.size() < 9:
		spawn_zombie()

var round_roman_text = ""
func increase_round():
	## Increase Difficulty
	## Decrease zombie spawn timer
	## Chaneg the round counter to go from Tallies to Arabic numerals after reaching round 10
	cur_round += 1
	
	
	change_difficulty()
	update_round_text()
	print("increasing round")

func update_round_text():
	
	var tally = player.round_container.get_child(cur_round)
	if cur_round <= 10:
		player.round_text.set("text", "")
		tally.set("texture", tally_texture)
		if cur_round == 5:
			player.round_container.get_child(1).set_texture(null)
			player.round_container.get_child(2).set_texture(null)
			player.round_container.get_child(3).set_texture(null)
			player.round_container.get_child(4).set_texture(null)
			tally.set("texture", tally_strike_texture)
		if cur_round == 10:
			player.round_container.get_child(6).set_texture(null)
			player.round_container.get_child(7).set_texture(null)
			player.round_container.get_child(8).set_texture(null)
			player.round_container.get_child(9).set_texture(null)
			tally.set("texture", tally_strike_texture)
	
	if cur_round > 10:
		player.round_container.get_child(5).set_texture(null)
		player.round_container.get_child(10).set_texture(null)
		player.round_text.set("text", cur_round)

func change_difficulty():
	## The plan here to is use the current round to affect the speed and damage zombies do.
	## Take the current level integer, use maths, modify the spawning logic of the instatiated zombie to modify their attrivutes upon spawning
	## Difficulty should probably be assigned within this game manager script, leavin the zombie prefab as a base/default character
	## Also change the maximum amount of zombies to spawn in the round
	## Also change the types of zombies to be spawned --
	
	cur_difficulty = cur_difficulty + (cur_round/10)
	print(cur_difficulty)
	pass

func spawn_zombie():
	#closest_spawner_to_player()
	#closest_spawner.spawn_zombie()
	choose_spawner()

func player_current_zone():
	for z in range(0, zones.size()):
		zones[z].check_for_player()
		if zones[z].is_player_in_zone:
			cur_zone = zones[z]
	print(cur_zone)

func choose_spawner():
	player_current_zone()
	var selected_spawn = randi_range(0, cur_zone.spawns.size() - 1)
	cur_zone.spawns[selected_spawn].spawn_zombie()

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
