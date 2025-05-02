extends Entity
class_name Player

@export var SPEED : float = 5.0
@export var JUMP_VELOCITY : float = 4.5
@export var MOUSE_SENSITIVITY : float = 0.5
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var CAMERA_CONTROLLER : Camera3D

@export var hold_offset: Vector3 = Vector3(0.5, -0.3, -.15) # droite, bas, vers l'avant
@export var hold_rotation_offset: Vector3 = Vector3(15, 160, 10) # en degrés

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _mouse_rotation : Vector3
var _player_rotation : Vector3
var _camera_rotation : Vector3
const inventory_max_size = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var in_vision_object : Interactable = null
@onready var hud : HUD = HudManager.hud
@onready var playerUI : PlayerUI = HudManager.player_item_hud
@onready var interaction_ray: InteractionRay = $InteractionRay
@onready var subMenu : SubItemMenu = HudManager.sub_menu_hud

var interaction_dict : Dictionary = {}

var current_index : int = 0
var object_cache : Array = []

func _unhandled_input(event: InputEvent) -> void:
	
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
		
	if event.is_action_pressed("MoveObject") and in_vision_object:
		print("moving...")
		var world_object : Node3D = in_vision_object.get_parent()
		
		if not can_object_move(world_object): return
		
		var pickable : Pickable = world_object.get_node("Pickable")
		pickable.interact(self)
		
		
func can_object_move(world_object : Node3D) -> bool:
	if world_object is not StaticBody3D: return false
	if not world_object.has_node("Pickable"): return false
	
	return true
	
	
		
		
func _update_camera(delta):
	
	# Rotates camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)

	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0

	_rotation_input = 0.0
	_tilt_input = 0.0
	
func _ready():

	# Get mouse input
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	object_cache.resize(10)

func _physics_process(delta):
	if subMenu.visible:
		return
	# Update camera movement based on mouse movement
	_update_camera(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
	pick_items()
## INTERACTION


	
func set_interaction(intraction_body: Interactable) -> void:
	if intraction_body:
		in_vision_object = intraction_body
		hud.show_interaction_label(intraction_body.key, intraction_body.interaction_name, intraction_body._name)
		return
	in_vision_object = null
	hud.show_crossair()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_tree().quit()
		
	if event.is_action_pressed("interact") and in_vision_object:
		in_vision_object.interact(self)
		interaction_ray.interact_body = null
		set_interaction(null)	
		
	if event.is_action_pressed("drop"):
		drop_item()
		
		
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var text = event.as_text()
		if text.is_valid_int():
			change_current_index(int(text))
		

func change_current_index(index : int) -> void:
	if index == 0:
		index = 9
	else:
		index -= 1
			
	if object_cache[current_index]:
		object_cache[current_index].visible = false
	
	current_index = index
	playerUI.select_new_item(current_index)
	
	

	
func updateUI() -> void:
	playerUI.update(inventory)
	for world_object in object_cache:
		if world_object:
			world_object.queue_free()
			
	object_cache.fill(null)
	

func get_visual_size(body: PhysicsBody3D) -> float:
	var mesh := body.get_node_or_null("MeshInstance3D")
	if mesh:
		return mesh.get_aabb().size.length()
	return 1.0

func _disable_physics(world_object : RigidBody3D) -> void:
	world_object.collision_layer = 0
	world_object.collision_mask = 0
	world_object.freeze = false
	world_object.gravity_scale = 0.0
	world_object.linear_damp = 10.0
	world_object.angular_damp = 10.0
	
func _enable_physics(world_object : RigidBody3D) -> void:
	world_object.collision_layer = 1
	world_object.collision_mask = 1
	world_object.freeze = false
	world_object.gravity_scale = 1
	world_object.linear_damp = 0.05
	world_object.angular_damp = 0.05
	

func process_rigid() -> void:
	if inventory.items[current_index].world_object: return
	
	if object_cache[current_index]:
		if object_cache[current_index].visible == false:
			pick_items()
			object_cache[current_index].visible = true
		return
	
	var item : ItemData = inventory.items[current_index]
	var scene : PackedScene = item.get_scene()
	
	object_cache[current_index] = scene.instantiate()
	get_tree().current_scene.add_child(object_cache[current_index])
	_disable_physics(object_cache[current_index])
	pick_items()


func process_static() -> void:
	if object_cache[current_index]: return
	var item : ItemData = inventory.items[current_index]
	var scene : PackedScene = item.get_scene()
	
	object_cache[current_index] = scene.instantiate()
	get_tree().current_scene.add_child(object_cache[current_index])
	
	var pickable : Pickable = object_cache[current_index].get_node("Pickable")
	assert(pickable)
	
	pickable.swap_shader()
	

func _process(_delta: float) -> void:
	if inventory.items[current_index] == null:
		return
	
	if inventory.items[current_index].physicBody == ItemData.PhysicBody.Rigid:
		process_rigid()
		
	if inventory.items[current_index].physicBody == ItemData.PhysicBody.Static:
		process_static()
		
	
		
	
	
	
	
func pick_items() -> void:
	if inventory.items[current_index] == null:
		return	
	if object_cache[current_index] == null : return
	
	var world_object: PhysicsBody3D = object_cache[current_index]
	if world_object.gravity_scale != 0.0:
		return

	# Obtenir la taille visuelle du mesh
	var size = get_visual_size(world_object)
	var scale_factor = clamp(1.0 / size, 0.4, 1.2)

	# Position décalée comme dans la main
	var offset = hold_offset + Vector3(0, 0, -size * 0.4)
	var target_position = CAMERA_CONTROLLER.global_transform.origin + CAMERA_CONTROLLER.global_transform.basis * offset

	# Rotation caméra + offset
	var base_rot = CAMERA_CONTROLLER.global_transform.basis.get_rotation_quaternion()
	var extra_rot = Quaternion.from_euler(Vector3(
		deg_to_rad(hold_rotation_offset.x),
		deg_to_rad(hold_rotation_offset.y),
		deg_to_rad(hold_rotation_offset.z)
	))
	var final_rot = base_rot * extra_rot

	# Appliquer position, rotation et scale
	world_object.global_transform.origin = target_position
	world_object.global_transform.basis = Basis(final_rot)
	world_object.scale = Vector3.ONE * scale_factor
	
	
func drop_item() -> void:
	if object_cache[current_index] == null: return
	var pickable : Pickable = object_cache[current_index].get_meta("interactable")
	if pickable == null: return	
	inventory.remove_single_item(current_index)
	object_cache[current_index] = null
	updateUI()
	pickable.drop(CAMERA_CONTROLLER)
	
