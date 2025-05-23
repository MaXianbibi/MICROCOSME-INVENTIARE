extends GridContainer
class_name SubItemMenu

const ITEM_UI = preload("res://HUD/ItemUI.tscn")
var item_ui_array : Array = []


var sub_inventory : Inventory = null

func init_sub_menu(inventory : Inventory) -> void:
	var menu_size : int = inventory.max_size
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	sub_inventory = inventory
	for n in menu_size:
		var item_ui : ItemUI = ITEM_UI.instantiate()
		item_ui.local_index = n
		item_ui.item = inventory.items[n]
		item_ui_array.append(item_ui)
		add_child(item_ui)
		item_ui.update()
	visible = true
	
func _update() -> void:
	if sub_inventory == null : return
	var menu_size : int = sub_inventory.max_size
	var item_ui_children : Array = get_children()
	
	for n in menu_size:
		if item_ui_children[n] is not ItemUI:
			push_error("pas normal ca, un child qui n'est pas itemUI :((")
			continue
			
		item_ui_children[n].item = sub_inventory.items[n]
		item_ui_children[n].update()


func _reset() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sub_inventory = null
	for item in item_ui_array:
		item.queue_free()
	item_ui_array.clear()



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit") and visible:
		_reset()
		get_viewport().set_input_as_handled()
