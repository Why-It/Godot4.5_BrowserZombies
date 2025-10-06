extends Node3D

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

var is_gun_done_firing = false

func _ready():
	pass


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "guns/ar_fire":
		pass
