extends Node3D

@export var wall_weapon : Node3D
@export var initial_price : int
@export var refill_price : int

var price = null

@onready var anim_player = $AnimationPlayer

var is_weapon_purchased = false

var player_ref = null

var can_interact = true
@onready var interact_timer = $Timer

func _ready() -> void:
	wall_weapon.set("visible", true)
	price = initial_price

func interacted():
	if can_interact:
		if !is_weapon_purchased && player_ref.points > price:
			player_ref.recieve_weapon(wall_weapon)
			player_ref.remove_points(price)
			anim_player.play("AnimLib_WallWapon/weapon_purchased")
			price = refill_price
			is_weapon_purchased = true
			print("purchasing wall weapon")
		elif is_weapon_purchased && player_ref.points > price:
			player_ref.buy_ammo(wall_weapon)
			player_ref.remove_points(price)
			print("buying ammo")
	
	can_interact = false
	interact_timer.start()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_ref = body
		body.able_to_interact = true
		body.interact_object = $"."


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.able_to_interact = false
		body.interact_object = null
		player_ref = null


func _on_timer_timeout() -> void:
	can_interact = true
