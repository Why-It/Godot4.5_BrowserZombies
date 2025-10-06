extends CharacterBody3D

##NOTES
## Need to add logic to buying doors
## Need to add logic to repairing barricade
## Need to add melee attack
## Perks
## Need to add buying guns

var health = 100
var max_health = 100
var cur_speed = 0.0
const walking_speed = 4.0
const sprint_speed = 5.5
const crouch_speed = 2.75
var movement_transition_velocity = 0.0625
const jump_vel = 4.5

var mouse_sens = 0.45
var fov_base = 65.0
const fov_change = 1.5

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var raycast = $head/Camera3D/RayCast3D
var gun_raycast = null
@onready var recenter_head_target = camera.rotation

@onready var pause_menu = $pause_menu

@export var equipped_gun = null
@export var current_weapon_index = 0
@export var weapons = []
@onready var weapon_icon_slot = $player_hud/BoxContainer3/BoxContainer3/BoxContainer2/BoxContainer2/weapon_/TextureRect

var max_camera_shake = 150
var min_camera_shake = 100
@onready var fire_rate = $fire_rate

@onready var magazine_text = $player_hud/BoxContainer3/BoxContainer3/BoxContainer2/BoxContainer2/magazine
@onready var ammo_reserve_text = $player_hud/BoxContainer3/BoxContainer3/BoxContainer2/BoxContainer2/reserve


@onready var points_text = $player_hud/BoxContainer3/BoxContainer/BoxContainer3/points
var points = 0


@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
var state_machine

@onready var blood_eyes = $Blood
var blood_opacity = 0.0

## HEAD BOB
var headbob_freq = 2.0
var headbob_amp = 0.08
var tick_headbob = 0.0

## Stairs
const max_step_height = 0.5
var _snapped_to_stairs_last_frame = false
var _last_frame_was_on_floor = -INF

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	weapons.append($head/Camera3D/arms/attach_point/weapon/handgun)
	equipped_gun = weapons[current_weapon_index]
	Switch_Weapon()
	update_points_text()
	state_machine = anim_tree.get("parameters/playback")
	anim_tree.set("active", true)


func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if event.is_action_pressed("next_gun"):
		Switch_Weapon()
	
	if event.is_action_pressed("DebugGiveWeapons"):
		Update_Weapon_Array("GiveAllWeapons")
	
	if event.is_action_pressed("shoot"):
		recenter_head_target = camera.rotation
	if event.is_action_released("shoot"):
		is_trigger_pulled = false


var recenter_head = false
var recenter_head_speed = 0.4
var recenter_head_time = 0.0
func _physics_process(delta):
	match state_machine.get_current_node():
		"Idle":
			if cur_speed > 0.15:
				anim_tree.set("parameters/conditions/Idle", false)
				anim_tree.set("parameters/conditions/Moving", true)
			elif cur_speed <= 0.15:
				anim_tree.set("parameters/conditions/Moving", false)
				anim_tree.set("parameters/conditions/Idle", true)
			pass
		"Walk":
			if cur_speed > walking_speed + 0.3:
				anim_tree.set("parameters/conditions/Walk", false)
				anim_tree.set("parameters/conditions/Run", true)
			elif cur_speed == walking_speed:
				pass
			elif cur_speed <= 0.15:
				anim_tree.set("parameters/conditions/Moving", false)
				anim_tree.set("parameters/conditions/Idle", true)
			pass
		"Run":
			if cur_speed >= sprint_speed:
				anim_tree.set("parameters/conditions/Run", true)
				anim_tree.set("parameters/conditions/Walk", false)
			elif cur_speed <= walking_speed + 0.15:
				anim_tree.set("parameters/conditions/Run", false)
				anim_tree.set("parameters/conditions/Walk", true)
			pass
		"Reload":
			pass
		pass
	
	if Input.is_action_pressed("shoot"):
		fire_gun()
	
	if Input.is_action_pressed("pause"):
		pause_menu._pause()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_vel
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor() or _snapped_to_stairs_last_frame:
		if direction:
			velocity.x = direction.x * cur_speed
			velocity.z = direction.z * cur_speed
			
			if Input.is_action_pressed("sprint"):
				##cur_speed = sprint_speed
				movement_transition_velocity = 0.75
				cur_speed = move_toward(cur_speed,sprint_speed,movement_transition_velocity)
			elif !Input.is_action_pressed("crouch"):
				##cur_speed = walking_speed
				movement_transition_velocity = 0.5
				cur_speed = move_toward(cur_speed,walking_speed,movement_transition_velocity)
			elif Input.is_action_pressed("crouch"):
				movement_transition_velocity = 0.5
				cur_speed = move_toward(cur_speed,crouch_speed,movement_transition_velocity)
		else:
			velocity.x = move_toward(velocity.x, 0, movement_transition_velocity)
			velocity.z = move_toward(velocity.z, 0, movement_transition_velocity)
			cur_speed = move_toward(cur_speed,0.0,movement_transition_velocity)
		## Stairs
		_last_frame_was_on_floor = Engine.get_physics_frames()
	else:
		velocity.x = lerp(velocity.x, direction.x * cur_speed, delta * 0.5)
		velocity.z = lerp(velocity.z, direction.z * cur_speed, delta * 0.5)
	
	if recenter_head:
		recenter_head_time += delta * recenter_head_speed
		camera.rotation = lerp(camera.rotation,recenter_head_target,recenter_head_time)
	
	## HEAD BOB
	tick_headbob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(tick_headbob)
	
	## FOV change when sprinting
	var velocity_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = fov_base + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	if not _snap_up_stairs_check(delta):
		
		move_and_slide()
		_snap_down_to_stairs_check()
	reset_head_from_camera_shake()
	update_health()
	
	## DEBUG ##
	if Input.is_action_just_pressed("debug_take_damage"):
		take_damage(15,Vector3.ZERO)


var raycast_target = null
var has_shot_cycled = true
var is_trigger_pulled = false
func fire_gun():
	if has_shot_cycled == true && is_trigger_pulled == false:
		recenter_head_target = camera.rotation
		fire_rate.start()
		if not equipped_gun.anim_player.is_playing():
			# put functions you want to only happen once per animation loop here
			equipped_gun.anim_player.play(equipped_gun.fire_anim_name)
			hit_scan()
			has_shot_cycled = false
			is_trigger_pulled = true
			
			if equipped_gun.automatic == true:
				is_trigger_pulled = false
		else:
			reset_head_from_camera_shake()
	else:
		reset_head_from_camera_shake()


func reset_head_from_camera_shake():
	if camera.rotation != recenter_head_target:
		recenter_head = true
	else:
		recenter_head = false
		recenter_head_time = 0.0
	equipped_gun.anim_player.stop()


func hit_scan():
	camera.rotation = lerp(camera.rotation, Vector3(deg_to_rad(randf_range(max_camera_shake, -max_camera_shake)), deg_to_rad(randf_range(max_camera_shake, -max_camera_shake)), 0.0025), deg_to_rad(0.5))
	
	raycast_target = raycast.get_collider()
	var enemy = find_enemy_root(raycast_target)
	
	if enemy != null:
		
		if raycast.get_collider().is_in_group("enemy_head"):
			enemy.hit(equipped_gun.damage * enemy.head_damage_modifier)
			add_points(20)
			bullet_hole(true)
			print("headshot")
		elif raycast.get_collider().is_in_group("enemy"):
			enemy.hit(equipped_gun.damage * enemy.limb_damage_modifier)
			add_points(10)
			bullet_hole(true)
			print("bodyshot")
	elif raycast_target != null:
		bullet_hole(false)

func find_enemy_root(node):
	while node != null:
		if node.is_in_group("enemy"):
			return node
		node = node.get_parent()
	return null

func bullet_hole(is_wound):
	if is_wound:
		var b = equipped_gun.bhole_wound_decal.instantiate()
		var bhole_location = raycast.get_collision_point()
		var bhole_rotation = raycast.get_collision_normal()
		raycast.get_collider().add_child(b)
		b.global_transform.origin = bhole_location
		b.look_at(bhole_location + bhole_rotation, Vector3.UP)
		if bhole_rotation == Vector3.UP:
			b.rotate_object_local(Vector3(1,0,0), deg_to_rad(180))
		else:
			pass
	else:
		var b = equipped_gun.bhole_decal.instantiate()
		var bhole_location = raycast.get_collision_point()
		var bhole_rotation = raycast.get_collision_normal()
		raycast.get_collider().add_child(b)
		b.global_transform.origin = bhole_location
		b.look_at(bhole_location + bhole_rotation, Vector3.UP)
		if bhole_rotation == Vector3.UP:
			b.rotate_object_local(Vector3(1,0,0), deg_to_rad(180))
		else:
			pass
		pass


func add_points(added_points: int):
	if not points >= 99999:
		points += added_points
		update_points_text()


func remove_points(reduction_amount: int):
	points -= reduction_amount
	update_points_text()


func update_points_text():
	points_text.set("text", points)


func update_ammo_count(magazine: int, reserve: int):
	magazine_text.set("text", magazine)
	ammo_reserve_text.set("text", reserve)


func Switch_Weapon():
	
	equipped_gun.visible = false
	if current_weapon_index == weapons.size()-1:
		current_weapon_index = 0
	else:
		current_weapon_index = current_weapon_index + 1
	equipped_gun = weapons[current_weapon_index]
	equipped_gun.visible = true
	weapon_icon_slot.texture = load(equipped_gun.weapon_icon)
	max_camera_shake = equipped_gun.max_camera_shake
	fire_rate.wait_time = equipped_gun.fire_rate
	gun_raycast = equipped_gun.get_node("gun/RayCast3D")
	
	pass


func Update_Weapon_Array(command):
	if command == "GiveAllWeapons":
		weapons.clear()
		weapons.append_array($head/Camera3D/arms/attach_point/weapon.get_children())
		print("Giving all weapons")
	pass


func _on_fire_rate_timeout() -> void:
	has_shot_cycled = true
	pass # Replace with function body.


var pushback = 3.0
func take_damage(damage, dir):
	health_regen = false
	health -= damage
	velocity += dir * pushback
	blood_opacity = move_toward(blood_opacity,blood_opacity+damage,0.25)
	if health <= 0:
		death()
		health = 0
		pass
	healing_cooldown_timer.start()
	pass


func update_health():
	blood_eyes.set("modulate", Color(1,1,1,blood_opacity))
	if health_regen && health < max_health:
		health = move_toward(health, max_health, health_regen_rate)
		blood_opacity = 1-(health/100)
	elif health_regen && health >= max_health:
		health = max_health
		health_regen = false
		blood_eyes.set("modulate", Color(1.0, 1.0, 1.0, 0.0))


func death():
	##death animation and game end
	print("player has died")
	pass

var health_regen = false
var health_regen_rate = 0.5
@onready var healing_cooldown_timer = $healing_cooldown
func _on_healing_cooldown_timeout() -> void:
	health_regen = true
	pass # Replace with function body.

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * headbob_freq) * headbob_amp
	pos.x = cos(time * headbob_freq / 2) * headbob_amp
	return pos


## Stairs
func _is_surface_too_steep(normal: Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle

func _run_body_test_motion(from: Transform3D, motion: Vector3, result = null) -> bool:
	if not result: result = PhysicsTestMotionResult3D
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func _snap_down_to_stairs_check() -> void:
	var did_snap := false
	var floor_below : bool = %StairsBelowRayCast3D2.is_colliding() and not _is_surface_too_steep(%StairsBelowRayCast3D2.get_collision_normal())
	var was_on_floor_last_frame = Engine.get_physics_frames() - _last_frame_was_on_floor == 1
	if not is_on_floor() and velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if _run_body_test_motion(self.global_transform, Vector3(0, -max_step_height,0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			did_snap = true
	_snapped_to_stairs_last_frame = did_snap

func _snap_up_stairs_check(delta) -> bool:
	if not is_on_floor() and not _snapped_to_stairs_last_frame: return false
	var expected_move_motion = self.velocity * Vector3(1,0,1) * delta
	var step_pos_with_clearance = self.global_transform.translated(expected_move_motion + Vector3(0, max_step_height * 2, 0))
	var down_check_result = PhysicsTestMotionResult3D.new()
	if (_run_body_test_motion(step_pos_with_clearance, Vector3(0, -max_step_height*2,0), down_check_result) and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y
		if step_height > max_step_height or step_height <= 0.01 or (down_check_result.get_collision_point() - self.global_position).y > max_step_height: return false
		%StairsAheadRayCast3D.global_position = down_check_result.get_collision_point() + Vector3(0, max_step_height, 0) + expected_move_motion.normalized() * 0.1
		%StairsAheadRayCast3D.force_raycast_update()
		if %StairsAheadRayCast3D.is_colliding() and not _is_surface_too_steep(%StairsAheadRayCast3D.get_collision_normal()):
			self.global_position = step_pos_with_clearance.origin + down_check_result.get_travel()
			apply_floor_snap()
			_snapped_to_stairs_last_frame = true
			return true
	return false
