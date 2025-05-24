extends Node
class_name Store

@export var nav : NavigationRegion3D = null

var interactible_list : Array[Interactable] = []

func find_nodes_of_type(type: String) -> Array:
	return nav.find_children("*", type, true, false)

func _ready() -> void:
	assert(nav)
	nav.set_meta("Store", self)
	nav.child_entered_tree.connect(_on_child_enter)
	nav.child_exiting_tree.connect(_on_child_exit)
	
	## GET ALL INTERACTIBLE AT THE START OF THE GAME ( EXEPT MOVABLE (PICKABLE CUS PROB USELESS) )	
	var uncast_interactable := find_nodes_of_type("Interactable")
	for inter in uncast_interactable:
		if inter is Pickable: continue
		interactible_list.append(inter as Interactable)
		
func _on_child_enter(node: Node) -> void:
	if node is not StaticBody3D: return
	call_deferred("rebake_nav", node)

func _on_child_exit(node: Node) -> void:
	if node is not StaticBody3D: return ## mini protection, mais pas convaincu
	call_deferred("rebake_nav", null)

func rebake_nav(node: Node) -> void:
	if not nav.is_inside_tree(): return
	nav.bake_navigation_mesh()
	if node == null:
		# Cleanup des références mortes
		interactible_list = interactible_list.filter(func(o): return o != null)
	elif node.has_meta("interactable"):
		var obj = node.get_meta("interactable")
		if obj is Interactable and not interactible_list.has(obj):
			interactible_list.append(obj)
		
## PAS SUPER OPTIMISER, PAS DE CACHE, ETC
func store_have_item(item : ItemData) -> PhysicsBody3D:
	for inventory in interactible_list:
		if inventory is not Inventory: continue
		if inventory.have_item(item): return inventory.parent
	return null

## PEUX AJOUTER AUSSI UN CACHE
func get_workstations_list() -> Array:
	return interactible_list.filter(func(inter): return inter is WorkingStation)
		
