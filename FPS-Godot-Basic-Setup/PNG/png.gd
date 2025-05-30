extends Entity
class_name NPC

@onready var skeletons : Skeleton3D = $Root/Skeleton
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@export var target : Node3D = null
@onready var look_at : LookAtModifier3D = $Root/Skeleton/lookat1
@onready var sub_menu : SubItemMenu = HudManager.sub_menu_hud
@onready var looking_for_timer: Timer = $LookingForTimer

@export var target_items_list : Array[ItemData] = []
var target_index : int = 0

@onready var stores_array : Array[Store] = EntityManager.stores_array
@onready var player : Player = EntityManager.player
const NECK = "Neck"
@onready var look_at_modifier_3d: LookAtModifier3D = $Label3D/LookAtModifier3D
var is_in_store : bool = false

var appartement : Appartement = null

var active : bool = true

enum AnimationState {
	Idle,
	Walking,
	Picking
}

@onready var label_3d: Label3D = $Label3D
const EVENT_STATE_TEXTS = ["Idle", "Looking", "Walking", "Picking", "Buying", "Leaving"]

enum EventState {
	IDLE,
	LOOKING,
	WALKING_TO,
	PICKING,
	BUYING,
	LEAVING
}

var eventState : EventState = EventState.LOOKING:
	set(value):
		eventState = value
		_update_label()

var animation_state : AnimationState = AnimationState.Idle
var last_animation_state : AnimationState = AnimationState.Picking
var current_store : Store = null

func _update_label():
	label_3d.text = EVENT_STATE_TEXTS[eventState]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target:
		animation_state = AnimationState.Walking
		look_at.target_node = target.get_path()
		navigation_agent_3d.target_position = target.global_position
	play_animation_state()
	_update_label()
	look_at_modifier_3d.target_node = player.get_path()
	
	appartement = EntityManager.get_free_appartement()
	
	## peut etre creer des sdf si ya pas dappart dispo
	#assert(appartement)
	

func new_target(new_target : Node3D) -> void:
	target = new_target
	animation_state = AnimationState.Walking
	look_at.target_node = target.get_path()
	navigation_agent_3d.target_position = target.global_position
	play_animation_state()
	
func play_animation_state() -> void:
	if animation_state == last_animation_state: return
	last_animation_state = animation_state
	match  animation_state:
		AnimationState.Idle:
			animation_tree.set("parameters/Transition/transition_request", "Idle")
		AnimationState.Walking:
			animation_tree.set("parameters/Transition/transition_request", "Walk")
		AnimationState.Picking:
			animation_tree.set("parameters/Transition/transition_request", "Pick")
			
func move_toward_target(delta) -> void:
	var destination := navigation_agent_3d.get_next_path_position()
	var direction := (destination - global_position).normalized()
	if direction.length() > 0.01:
		var target_rotation := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, delta * 5.0)
	# Applique le mouvement seulement si utile
	velocity = direction * 3.0
	move_and_slide()

func _physics_process(delta: float) -> void:
	if not active: return
	
	match eventState:
		## DOING NOTHING / STALL IN APPARTEMENT
		EventState.IDLE:
			return
		## REGULATE BY TIMER
		EventState.LOOKING:
			return
		EventState.WALKING_TO:
			move_toward_target(delta)
		EventState.PICKING:
			return
		EventState.BUYING:				
			if target == null:
				look_for_nearest_counter()
			move_toward_target(delta)
		EventState.LEAVING:
			move_toward_target(delta)
			
func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	
	if body.has_meta("interactable"):
		var door : Interactable = body.get_meta("interactable")
		if door is OpenDoor:
			if !is_in_store or eventState == EventState.LEAVING:
				door.interact(self)
				is_in_store = !is_in_store
				
				print(is_in_store)
			
	if body == target:		
		if eventState == EventState.WALKING_TO:
			eventState = EventState.PICKING
			take_from_inventory(body)
		
		
			
func drop_first_item() -> void:
	var item : ItemData = inventory.items[0]
	if item == null: return
	
	var scene : PackedScene = item.get_scene()
	var world_object : PhysicsBody3D = scene.instantiate()
	get_tree().current_scene.add_child(world_object)
	inventory.remove_single_item(0)
	var pickable : Pickable = world_object.get_meta("interactable")
	assert(pickable)
	pickable.drop(self)
	
func take_an_item(body : PhysicsBody3D) -> void:
	var interactable = body.get_meta("interactable")
	if interactable == null: return
	if interactable is not Pickable: return
		
	animation_state = AnimationState.Picking
	play_animation_state()
	await get_tree().create_timer(0.7).timeout
	interactable.interact(self)		

func _on_looking_for_timer_timeout() -> void:
	if eventState != EventState.LOOKING: return
	if target_items_list.size() == target_index:
		return
		
	for store in stores_array:
		var shelf : PhysicsBody3D = store.store_have_item(target_items_list[target_index])
		if shelf:
			current_store = store
			new_target(shelf)
			eventState = EventState.WALKING_TO
			return
			

func take_from_inventory(body : PhysicsBody3D) -> void:
	var interactable = body.get_meta("interactable")
	if interactable is not Inventory: return
	
	## Check, if its there, remove items and return true, else false
	animation_state = AnimationState.Picking
	play_animation_state()
	await get_tree().create_timer(0.7).timeout
	if interactable.remove_item_by_id(target_items_list[target_index]) == false: return
	
	inventory.add_item(target_items_list[target_index])
	target_index += 1
	
	if target_index < target_items_list.size(): eventState = EventState.LOOKING
	else:
		target = null
		eventState = EventState.BUYING
	
func look_for_nearest_counter() -> void:
	var workstations_list: Array = current_store.get_workstations_list()
	var my_position: Vector3 = global_position # ou un autre point de référence
	
	if workstations_list.is_empty():
		return
	var nearest_workstation : Node3D = null
	
	if workstations_list.size() == 1:
		nearest_workstation = workstations_list[0].get_next_client_spot()
	else:
		assert(false)
	new_target(nearest_workstation)


func _on_navigation_agent_3d_navigation_finished() -> void:
	if eventState == EventState.BUYING:
		buying()
	elif eventState == EventState.LEAVING:
		deactivate()
		
func buying() -> void:
	look_at.target_node = player.CAMERA_CONTROLLER.get_path()
	animation_state = AnimationState.Picking
	play_animation_state()
	await get_tree().create_timer(0.7).timeout
	target = null
	eventState = EventState.LEAVING
	new_target(appartement.get_apparetement_node())
	animation_state = AnimationState.Walking
	play_animation_state()
	
func deactivate():
	hide()
	active = false
	await get_tree().process_frame

	set_process_mode(Node.PROCESS_MODE_DISABLED)

	#global_position = Vector3(9999, -1000, 9999)

	


func activate() -> void:
	show()
	active = true
	set_process_mode(Node.PROCESS_MODE_INHERIT)
	
