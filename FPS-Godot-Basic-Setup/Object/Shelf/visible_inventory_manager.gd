extends Node3D
class_name VisibleInventoryManager

var marker_array : Array[Marker3D] = []
var object_array : Array[PhysicsBody3D] = []

@export var test_scene : PackedScene = null
@export var inventory : Inventory = null

func _ready() -> void:
	assert(inventory)
	marker_array.append_array(find_children("*", "Marker3D", false, false))
	object_array.resize(marker_array.size())
	
	inventory.add_new_item.connect(add_object)
	inventory.remove_item.connect(remove_object)
	inventory.signal_swap_item.connect(swap_items)

func add_object(item : ItemData, index : int) -> void:
	var new_scene : PackedScene = item.get_scene()
	
	var new_object : PhysicsBody3D = new_scene.instantiate()
	new_object.freeze = true
	add_child(new_object)
	new_object.collision_layer = 0
	new_object.collision_mask = 0
	new_object.global_position = marker_array[index].global_position
	object_array[index] = new_object
		
func remove_object(index : int) -> void:
	object_array[index].queue_free()
	object_array[index] = null


func swap_items(old_index: int, new_index: int) -> void:
	if old_index >= 0 and new_index >= 0 and old_index < object_array.size() and new_index < object_array.size():
		var temp = object_array[old_index]
		object_array[old_index] = object_array[new_index]
		object_array[new_index] = temp
		
		if object_array[old_index]:
			object_array[old_index].global_position = marker_array[old_index].global_position
		if object_array[new_index]:
			object_array[new_index].global_position = marker_array[new_index].global_position
	
