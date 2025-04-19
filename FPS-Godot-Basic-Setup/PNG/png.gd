extends CharacterBody3D

@onready var skeletons : Skeleton3D = $Root/Skeleton

const NECK = "Neck"
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

var time_passed: float = 0.0

@export var target : Node3D = null
@onready var look_at : LookAtModifier3D = $Root/Skeleton/lookat1
@onready var player : Node3D = EntityManager.player as Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_path_to(player))
	var bone_index = skeletons.find_bone("Neck")	
	print("NECK INDEX:", bone_index)

	look_at.target_node = player.get_path() # ✔️ Godot accepte ici une Node3D

func _physics_process(delta: float) -> void:
	navigation_agent_3d.target_position = player.global_position
	
	var destination = navigation_agent_3d.get_next_path_position()
	var local_destination = destination - global_position
	var direction = local_destination.normalized()

	# Rotation douce vers la cible
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		var new_rotation = lerp_angle(rotation.y, target_rotation, delta * 5.0)
		rotation.y = new_rotation

	# Mouvement
	velocity = direction * 1.0
	move_and_slide()

	
func _on_area_3d_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	print("yooo")
