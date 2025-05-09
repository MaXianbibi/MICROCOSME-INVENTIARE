extends Node
class_name Store

@onready var parent : Node3D = get_parent()
var inventories : Array[Inventory] = []
@export var nav : NavigationRegion3D = null

func update_inventories() -> void:
	var result: Array[Inventory] = []
	for child in parent.find_children("*", "", true, false):
		if child is Inventory:
			result.append(child as Inventory)
	inventories = result

func _ready() -> void:
	assert(parent)
	assert(nav)
	nav.child_entered_tree.connect(_on_child_enter)
	nav.child_exiting_tree.connect(_on_child_exit)
	update_inventories()

func _on_child_enter(node: Node) -> void:
	if node is not StaticBody3D: return
	update_inventories()
	call_deferred("rebake_nav")

func _on_child_exit(node: Node) -> void:
	if node is not StaticBody3D: return ## mini protection, mais pas convaincu
	update_inventories()
	call_deferred("rebake_nav")

func rebake_nav() -> void:
	if nav.is_inside_tree():
		nav.bake_navigation_mesh()
