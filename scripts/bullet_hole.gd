extends Node3D

@onready var bhole = $Sprite3D
@onready var timer = $Timer
@onready var fade_timer = $fade_timer

var is_fading = false
var bhole_opacity = 1


func _on_timer_timeout():
	fade_timer.start()
	is_fading = true

func _process(delta):
	
	if is_fading:
		bhole_opacity *= lerp(1,0,0.5*delta)
		bhole.set("modulate", Color(1,1,1,bhole_opacity))

func _on_fade_timer_timeout():
	queue_free()
