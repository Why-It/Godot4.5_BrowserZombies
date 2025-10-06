extends Node

var current_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	# This function should be called from a signal callback or some other runnign function from the running scene.
	# Deleting the current scene at this point may be a bad idea, because it may be inside fo a callback or function of it.
	# The worst case will be a crash or unexpected behavior.
	
	# The way aroudn this is deffering the load to a later time when it is ensured that no code from the current scene is running.
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# Immediately free the current scene, there's no risk here.
	current_scene.free()
	
	# Load new scene
	var s = ResourceLoader.load(path)
	
	# Instatiate the new scene
	current_scene = s.instantiate()
	
	# Add it to the active scene as a child of the root.
	get_tree().get_root().add_child(current_scene)
	
	# Optional, to make it compatible with the SceneTree.change_scene() API
	get_tree().set_current_scene(current_scene)
