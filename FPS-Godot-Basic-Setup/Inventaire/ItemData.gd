extends Resource
class_name ItemData



@export var id: String
@export var name: String
@export var size: int = 1
@export var description: String
@export var icon: Texture2D
@export var max_stack_size: int = 20
@export var weight: float = 1.0
@export var item_type: String = "generic"
@export var tradable: bool = true
@export var item_scene: String
@export var custom_data: Dictionary = {}
@export var local_index : int = 0

enum PhysicBody {
	Static,
	Rigid
}

@export var physicBody : PhysicBody = PhysicBody.Rigid
@export var world_object_texture: Material = null

var world_object : PhysicsBody3D = null
var loaded_scene : PackedScene = null



func get_scene() -> PackedScene:
	assert(item_scene)
	if loaded_scene: return loaded_scene
	loaded_scene = load(item_scene)
	return loaded_scene
	
func can_add(amount: int = 1) -> bool:
	return size + amount <= max_stack_size

func can_remove(amount: int = 1) -> bool:
	return size - amount >= 0

func add(amount: int = 1) -> bool:
	if can_add(amount):
		size += amount		
		return true
	return false

func add_max():
	size = max_stack_size

func remove_max():
	size = 0

func remove(amount: int = 1) -> bool:
	if can_remove(amount):
		size -= amount
		return true
	return false
	
