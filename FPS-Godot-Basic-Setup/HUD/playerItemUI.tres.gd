extends HBoxContainer
class_name PlayerUI

@onready var player : Player = EntityManager.player
const ITEM_UI = preload("res://HUD/ItemUI.tscn")

var current_index : int = 0

var item_ui_array : Array = []

func _ready() -> void:
	var player_inventory_size  : int = player.inventory_max_size
	
	for n in player_inventory_size:
		var item_ui : ItemUI = ITEM_UI.instantiate()
		item_ui.local_index = n
		item_ui_array.append(item_ui)
		add_child(item_ui)
		
	item_ui_array[current_index].select()

func update(inventory : Inventory) -> void:
	for n in inventory.max_size:
		print(inventory.items[n])
		item_ui_array[n].item = inventory.items[n]
		item_ui_array[n].update()
		
func select_new_item(index : int) -> void:

	item_ui_array[current_index].unselect()
	current_index = index
	item_ui_array[current_index].select()
	
		
