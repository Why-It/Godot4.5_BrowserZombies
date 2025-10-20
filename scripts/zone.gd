extends Area3D

@export var spawns : Array[Node]

@onready var collider = $CollisionShape3D

var is_player_in_zone = false

func _ready() -> void:
	pass

var overlapping_bodies = []

func check_for_player():
	
	is_player_in_zone = false
	
	for b in range(0, overlapping_bodies.size()):
		if overlapping_bodies[b].is_in_group("player"):
			is_player_in_zone = true
		else:
			pass
	
	#print("overlapping bodies in ", self.name, ": ", overlapping_bodies)
	return is_player_in_zone


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		overlapping_bodies.append(body)
	elif body.is_in_group("enemy"):
		overlapping_bodies.append(body)
	else:
		pass


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		overlapping_bodies.erase(body)
	elif body.is_in_group("enemy"):
		overlapping_bodies.erase(body)
	else:
		pass
