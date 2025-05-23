extends Entity
class_name NPC

@onready var skeletons : Skeleton3D = $Root/Skeleton
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@export var target : Node3D = null
@onready var look_at : LookAtModifier3D = $Root/Skeleton/lookat1
@onready var sub_menu : SubItemMenu = HudManager.sub_menu_hud
@onready var looking_for_timer: Timer = $LookingForTimer
@export var target_item : ItemData = null
@onready var stores_array : Array[Store] = EntityManager.stores_array

@onready var player : Player = EntityManager.player

const NECK = "Neck"
var task_finish : bool = false

@onready var look_at_modifier_3d: LookAtModifier3D = $Label3D/LookAtModifier3D

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
	

func new_target(new_target : Node3D) -> void:
	target = new_target
	animation_state = AnimationState.Walking
	eventState = EventState.WALKING_TO
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
	velocity = direction * 1.0
	move_and_slide()

func _physics_process(delta: float) -> void:
	if target == null: return
	
	match eventState:
		EventState.IDLE:
			return
		EventState.LOOKING:
			return
		EventState.WALKING_TO:
			move_toward_target(delta)
		EventState.PICKING:
			return
		EventState.BUYING:
			return
		EventState.LEAVING:
			return
			

func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body == target:
		print("yooo")
		if eventState == EventState.WALKING_TO:
			eventState = EventState.PICKING
			take_from_inventory(body)
			
		#task_finish = true
		#interactable = body.get_meta("interactable")
		#if interactable is Pickable:
			#take_an_item(interactable)
			#await get_tree().create_timer(2).timeout
			#drop_first_item()
			#task_finish = false
			#new_target(get_tree().get_first_node_in_group("Shelf"))
			#return
			#
		#if interactable is Inventory:
			#var items : ItemData = inventory.items[0]
			#inventory.remove_single_item(0)
			#interactable.add_single_item(items)
			#if sub_menu.visible:
				#sub_menu._update()
			#animation_state = AnimationState.Picking
			#play_animation_state()
			#interactable = null
			
			
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
	
	for store in stores_array:
		var shelf : PhysicsBody3D = store.store_have_item(target_item)
		if shelf:
			new_target(shelf)
			return
			
	print("no item found :(")

func take_from_inventory(body : PhysicsBody3D) -> void:
	var interactable = body.get_meta("interactable")
	if interactable is not Inventory: return
	
	## Check, if its there, remove items and return true, else false
	animation_state = AnimationState.Picking
	play_animation_state()
	await get_tree().create_timer(0.7).timeout
	
	
	if interactable.remove_item_by_id(target_item) == false: return
	inventory.add_item(target_item)
	
	
	eventState = EventState.BUYING
		
	
