extends Node
class_name Store

var inventories : Array[Inventory] = []
@export var nav : NavigationRegion3D = null

func update_inventories() -> void:
	var result: Array[Inventory] = []
	inventories.clear()
	for child in nav.find_children("*", "", true, false):
		if child is Inventory:
			result.append(child as Inventory)
	inventories = result
	print("NEW INVENTORY : ", inventories)

func _ready() -> void:
	assert(nav)
	nav.set_meta("Store", self)
	nav.child_entered_tree.connect(_on_child_enter)
	nav.child_exiting_tree.connect(_on_child_exit)
	update_inventories()

func _on_child_enter(node: Node) -> void:
	if node is not StaticBody3D: return
	call_deferred("rebake_nav")

func _on_child_exit(node: Node) -> void:
	if node is not StaticBody3D: return ## mini protection, mais pas convaincu
	call_deferred("rebake_nav")

func rebake_nav() -> void:
	if nav.is_inside_tree():
		nav.bake_navigation_mesh()
		update_inventories()
		
func store_have_item(item : ItemData) -> PhysicsBody3D:
	for inventory in inventories:
		if inventory.have_item(item): return inventory.parent
	return null
		
		
