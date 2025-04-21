extends Interactable
class_name Inventory

var items: Array = []

@export var max_size : int = 10
var current_index : int = 0

@onready var sub_menu_hud : SubItemMenu = HudManager.sub_menu_hud

func interact(body : Entity = null) -> void:
	sub_menu_hud.init_sub_menu(self)


func init() -> void:
	interaction_name = "Access to "
	_name = "shelf storage"
	items.resize(max_size)

func add_to_array(item : ItemData) -> bool:
	var index = items.find(null)
	if index == -1:
		return false
	
	var new_item : ItemData = item.duplicate(true)
	new_item.size = 1
	new_item.local_index = index
	new_item.world_object = null
	items[index] = new_item
	return true

func add_single_item(item_data: ItemData) -> bool:
	var item_index = items.find_custom(func(item): 
		if item == null: return false	
		return item.id == item_data.id and item.size < item.max_stack_size
	)

	if item_index == -1:
		return add_to_array(item_data)	
	var item : ItemData = items[item_index]
	if item.add(1) == false:
		return add_to_array(item_data)
		
	return true
	
func add_item(item_data: ItemData) -> int:
	for n in item_data.size:
		if add_single_item(item_data) == false:
			return item_data.size - n
	return 0
	

func remove_single_item(index : int) -> bool:
	var item : ItemData = items[index]
	if item == null: return false
	if item.remove(1) == false:
		return false
	if item.size == 0:
		items[index] = null
	return true
	
func logs() -> void:
	print("---------------------------------------------")
	for item in items:
		if item:
			print("NAME : ", item.name, " | SIZE : ", item.size, " | LOCAL INDEX : ", item.local_index)
	print("---------------------------------------------")
