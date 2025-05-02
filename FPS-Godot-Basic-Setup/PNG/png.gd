extends Entity
class_name NPC

@onready var skeletons : Skeleton3D = $Root/Skeleton
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@export var target : Node3D = null
@onready var look_at : LookAtModifier3D = $Root/Skeleton/lookat1

@onready var sub_menu : SubItemMenu = HudManager.sub_menu_hud

const NECK = "Neck"
var task_finish : bool = false

var interactable : Interactable = null


enum State {
	Idle,
	Walking,
	Picking
}

var state : State = State.Idle
var last_state : State = State.Picking

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target:
		state = State.Walking
		look_at.target_node = target.get_path()
		navigation_agent_3d.target_position = target.global_position
	play_animation_state()


func new_target(new_target : Node3D) -> void:
	target = new_target
	state = State.Walking
	look_at.target_node = target.get_path()
	navigation_agent_3d.target_position = target.global_position
	
	play_animation_state()
	
	

func play_animation_state() -> void:

	if state == last_state: return
	last_state = state
	
	match  state:
		State.Idle:
			animation_tree.set("parameters/Transition/transition_request", "Idle")
		State.Walking:
			animation_tree.set("parameters/Transition/transition_request", "Walk")
		State.Picking:
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
	if not task_finish: move_toward_target(delta)


func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body == target:
		task_finish = true
		interactable = body.get_meta("interactable")
		if interactable is Pickable:
			take_an_item(interactable)
			await get_tree().create_timer(2).timeout
			drop_first_item()
			
			task_finish = false
			new_target(get_tree().get_first_node_in_group("Shelf"))
			
			return
			
		if interactable is Inventory:
			var items : ItemData = inventory.items[0]
			inventory.remove_single_item(0)
			interactable.add_single_item(items)
			
			if sub_menu.visible:
				sub_menu._update()
			
			
			state = State.Picking
			play_animation_state()
			
			
			
			interactable = null
			
			
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

	
func take_an_item(interactable : Pickable) -> void:
	if interactable == null: return
		
	state = State.Picking
	play_animation_state()
	await get_tree().create_timer(0.7).timeout
	interactable.interact(self)
	interactable = null
		
