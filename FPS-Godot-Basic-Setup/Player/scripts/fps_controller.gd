extends Entity
class_name Player

const SNAP_ANGLE := deg_to_rad(45)
const SNAP_STRENGTH := 0.2 # 0.0 = ignore le snap, 1.0 = snap immédiat



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

func snap_object_rotation(obj: Node3D, direction: float) -> void:
	var static_obj := obj as StaticBody3D
	if static_obj == null:
		return

	var angle := wrapf(static_obj.rotation.y, 0.0, TAU)

	var snapped_angle: float
	if direction > 0.0:
		snapped_angle = ceil(angle / SNAP_ANGLE) * SNAP_ANGLE
	else:
		snapped_angle = floor(angle / SNAP_ANGLE) * SNAP_ANGLE

	var rot := static_obj.rotation
	rot.y = snapped_angle
	static_obj.rotation = rot






func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		
	if event.is_action_pressed("MoveObject") and in_vision_object:
		var world_object : Node3D = in_vision_object.get_parent()
		if not can_object_move(world_object): return
		var pickable : Pickable = world_object.get_node("Pickable")
		pickable.interact(self)
		
	if event.is_action_pressed("shoot"):
		if object_cache[current_index] is StaticBody3D:
			place_static_object()
			
	if event.is_action_released("drop"):
		if object_cache[current_index] is StaticBody3D:
			snap_object_rotation(object_cache[current_index], 1)
		
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
	
	if Input.is_action_pressed("drop"):
		drop_item()
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
		
	#if event.is_action("drop"):
		#drop_item()
		
		
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
	if object_cache[current_index]:
		if object_cache[current_index].visible == false: 
			object_cache[current_index].visible = true
		return
		
	var item : ItemData = inventory.items[current_index]
	var scene : PackedScene = item.get_scene()
	object_cache[current_index] = scene.instantiate()
	get_tree().current_scene.add_child(object_cache[current_index])
	
	
	object_cache[current_index].global_rotation = global_rotation
	
	snap_object_rotation(object_cache[current_index], 0)
	
	var pickable : Pickable = object_cache[current_index].get_node("Pickable")
	assert(pickable)
	
	pickable._disable_static_physics()	
	pickable.set_select_shader()
	
func _process(_delta: float) -> void:
	if inventory.items[current_index] == null:
		return
	
	if inventory.items[current_index].physicBody == ItemData.PhysicBody.Rigid:
		process_rigid()
		
	if inventory.items[current_index].physicBody == ItemData.PhysicBody.Static:
		process_static()


func pick_rigid_object() -> void:
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
	

func pick_items() -> void:
	if inventory.items[current_index] == null:
		return	
	if object_cache[current_index] == null : return
	
	if object_cache[current_index] is  RigidBody3D: pick_rigid_object()
	elif object_cache[current_index] is StaticBody3D: pick_static_object()
	

func drop_rigid() -> void:
	var pickable : Pickable = object_cache[current_index].get_meta("interactable")
	if pickable == null: return	
	inventory.remove_single_item(current_index)
	object_cache[current_index] = null
	updateUI()
	pickable.drop(CAMERA_CONTROLLER)
	

func apply_snapped_rotation(obj: StaticBody3D, amount: float) -> void:
	obj.rotate_y(amount)


	
func drop_item() -> void:
	if object_cache[current_index] == null: return
	if object_cache[current_index] is RigidBody3D: drop_rigid()
	elif object_cache[current_index] is StaticBody3D: apply_snapped_rotation(object_cache[current_index], .0625)
	
	
func pick_static_object() -> void:
	var result: Dictionary = interaction_ray.interact_cast(1000.0)
	if result.is_empty():
		return

	# Récupération de l'objet courant
	var obj: Node3D = object_cache[current_index]

	# Appliquer un snap facultatif
	var snap_size: float = .5
	var snapped_pos: Vector3 = result["position"].snapped(Vector3(snap_size, snap_size, snap_size))
	obj.global_position = snapped_pos

	# Vérifier si l'objet peut être placé à cette position
	var can_place: bool = can_place_object(obj)

	# Appliquer le retour visuel
	if obj.has_meta("objectData"):
		var object_data: objectData = obj.get_meta("objectData") as objectData
		if object_data:
			object_data.change_select_color(can_place)

	
	
## pas trop didee a savoir comment sa marche, peut probablement causer probleme dans le futur.
func can_place_object(obj: Node3D) -> bool:
	# Récupère la première CollisionShape3D trouvée dans l'objet
	var shape_node: CollisionShape3D = obj.get_node_or_null("CollisionShape3D")
	if shape_node == null or shape_node.shape == null:
		return true  # Aucun shape = rien à tester

	var space_state: PhysicsDirectSpaceState3D = obj.get_world_3d().direct_space_state
	var shape: Shape3D = shape_node.shape

	var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = shape_node.global_transform
	query.exclude = [obj.get_rid()]
	query.collision_mask = 1

	var results: Array = space_state.intersect_shape(query, 10)
	for result_dict in results:
		var result: Dictionary = result_dict as Dictionary
		var collider: Node = result.get("collider") as Node
		if collider != null and not collider.is_in_group("no_blocking"):
			return false

	return true


func place_static_object() -> void:
	var world_object : StaticBody3D = object_cache[current_index]
	if not can_place_object(world_object): return
	
	inventory.remove_single_item(current_index)	
	object_cache[current_index] = null
	updateUI()
	set_interaction(null)
	
	world_object.collision_layer = 1
	world_object.collision_mask = 1
	
	var object_data: objectData = world_object.get_meta("objectData")
	object_data.set_item_mat()
	
	
