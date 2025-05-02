extends Interactable
class_name Pickable


@export var hold_distance: float = 0.5
@export var pickup_speed: float = 10.0
@export var hold_offset: Vector3 = Vector3(0.3, -0.3, -0.5)
@export var hold_rotation_offset: Vector3 = Vector3(10, 180, 0)
@export var throw_force: float = 10.0

#@onready var original_texture : Texture2D = texture

const OUTLINE = preload("res://Object/OutlineShader/Outline.gdshader")

var object_data : objectData = null
var controller : Entity = null
var is_in_transition : bool = false

func init() -> void:
	await get_tree().process_frame
	interaction_name = "pick up "
	
	if parent.has_meta("objectData"):
		object_data = parent.get_meta("objectData")
		
		if object_data:
			object_data.item_data.world_object = parent
			_name = object_data.item_data.name

func set_object_data() -> void:
	object_data = parent.get_meta("objectData")
	assert(object_data)
	
	if object_data and object_data.item_data:
		object_data.item_data = object_data.item_data.duplicate(true)
		_name = object_data.item_data.name
		
func transition(delta : float) -> void:
	if parent is not RigidBody3D: return
	
	var target_position = controller.global_transform.origin + controller.global_transform.basis * hold_offset
	var target_rot = controller.global_transform.basis.get_rotation_quaternion()
	var offset_rot = Quaternion.from_euler(Vector3(
		deg_to_rad(hold_rotation_offset.x),
		deg_to_rad(hold_rotation_offset.y),
		deg_to_rad(hold_rotation_offset.z)
	))
	var final_target_rot = target_rot * offset_rot

	if is_in_transition:
		var current_position = parent.global_transform.origin
		var new_position = current_position.lerp(target_position, delta * pickup_speed)
		parent.global_transform.origin = new_position

		var current_rot = parent.global_transform.basis.get_rotation_quaternion()
		var new_rot = current_rot.slerp(final_target_rot, delta * pickup_speed)
		parent.global_transform.basis = Basis(new_rot)
		
		if current_position.distance_to(target_position) < 1.5:
			is_in_transition = false
			_disable_physics()
			parent.hide()
			parent.queue_free()
			object_data.item_data.world_object = null
	return
	
	
	
func interact(body : Entity = null) -> void:
	if body == null: return
	if object_data == null: set_object_data()
	var inventory : Inventory = body.inventory
	if inventory == null:
		push_error("Entity has no Inventory")
		return
		
		
	controller = body
	is_in_transition = true
	
	var remaning : int = inventory.add_item(object_data.item_data)	
	if body is Player: body.updateUI()	
	
	if parent is StaticBody3D: parent.queue_free()
	

func _physics_process(delta: float) -> void:
	if is_in_transition:
		transition(delta)
	


func _disable_physics() -> void:
	parent.collision_layer = 0
	parent.collision_mask = 0
	parent.freeze = false
	parent.gravity_scale = 0.0
	parent.linear_damp = 10.0
	parent.angular_damp = 10.0
	
func _enable_physics() -> void:
	parent.collision_layer = 1
	parent.collision_mask = 1
	parent.freeze = false
	parent.gravity_scale = 1
	parent.linear_damp = 0.05
	parent.angular_damp = 0.05
	

func _reset() -> void:
	_enable_physics()
	#
	set_object_data()
	object_data.item_data.size = 1
	
	
	# Reset complet du transform
	parent.linear_velocity = Vector3.ZERO
	parent.angular_velocity = Vector3.ZERO
	parent.sleeping = false
	parent.freeze = false
	
	# On reconstruit une base propre sans rotation
	var origin = parent.global_transform.origin
	parent.global_transform = Transform3D(Basis(), origin)

	parent.scale = Vector3.ONE
	parent.visible = true
	



func drop(controller : Node3D = null) -> void:
	var forward_dir = null
	if controller is Camera3D:
		forward_dir = controller.global_transform.basis.z * -1
	else:
		forward_dir = controller.global_transform.basis.z.normalized()

	parent.global_transform.origin = controller.global_transform.origin + forward_dir * 1.0

	_reset()

	# Appliquer une légère rotation random (facultatif, visuel naturel)
	var random_rot = Basis()
	random_rot = random_rot.rotated(Vector3.UP, randf_range(-0.3, 0.3))
	random_rot = random_rot.rotated(Vector3.RIGHT, randf_range(-0.2, 0.2))
	parent.global_transform.basis = random_rot

	# Impulsion vers l’avant
	parent.apply_central_impulse(forward_dir * throw_force)

func _disable_static_physics() -> void:
	parent.collision_layer = 0
	parent.collision_mask = 0

func set_select_shader() -> void:
	if object_data == null: set_object_data()
		
	var outline_shader : ShaderMaterial = TextureManager.get_select_static_shader()
	object_data.set_mat(outline_shader)

	
func change_select_color() -> void:
	if object_data == null: set_object_data()
	
	
	
