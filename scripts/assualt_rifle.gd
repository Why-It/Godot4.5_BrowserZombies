extends Node3D

var cur_reserve_ammo = 0
var max_reserve_ammo = 108
var cur_mag_ammo = 0
var max_mag_ammo = 18
var damage = 25
var automatic = false
var fire_rate = 0.15
var max_camera_shake = 200

var gun_name = "Handgun"

const fire_anim_name = "guns/ar_fire"

@onready var anim_player = $AnimationPlayer
@onready var bhole_decal = preload("res://blueprints_prefabs/bullet_hole_placeholder.tscn")
@onready var bhole_wound_decal = preload("res://blueprints_prefabs/bullet_hole_wound.tscn")

@onready var weapon_icon = "res://textures/rifle128.png"

@onready var sights = $gun/components/sight
@onready var foregrip = $gun/components/foregrip
@onready var handle = $gun/components/handle
@onready var trigger_gueard = $"gun/components/trigger-guard"
@onready var body = $gun/components/body
@onready var magazine = $gun/components/mag
@onready var optic = $gun/components/optic

@onready var crosshair_comp = $crosshair
@onready var crosshair_img = $crosshair/CenterContainer/TextureRect

var can_gun_fire = true
var is_gun_done_firing = false
var is_reloading = false

func _ready():
	cur_mag_ammo = max_mag_ammo
	cur_reserve_ammo = max_reserve_ammo

func _mag_reload():
	if cur_mag_ammo != max_mag_ammo:
		if cur_reserve_ammo > 0:
			anim_player.play("guns/tg_reload")
			is_reloading = true
		else:
			pass
	else:
		pass

func _mag_reloaded():
	var transfering_ammo = 0
	if cur_reserve_ammo >= max_mag_ammo:
		cur_reserve_ammo += cur_mag_ammo
		transfering_ammo = max_mag_ammo
	else:
		transfering_ammo = cur_reserve_ammo
	cur_reserve_ammo -= transfering_ammo
	cur_mag_ammo = transfering_ammo
	is_reloading = false
	can_gun_fire = true


func _trigger_pulled():
	anim_player.stop()
	if cur_mag_ammo > 0:
		anim_player.play(fire_anim_name)
		can_gun_fire = true
		cur_mag_ammo -= 1
	else:
		can_gun_fire = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "guns/ar_fire":
		pass
