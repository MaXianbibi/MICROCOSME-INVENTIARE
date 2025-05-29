extends Node

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var stores_array : Array[Store] = []
@onready var appartements_array : Array[Appartement] = []

func _ready() -> void:
	var store_groupes = get_tree().get_nodes_in_group("Stores")
	for store in store_groupes:
		if store is Store:
			stores_array.append(store)
	
	var appartements_groupe = get_tree().get_nodes_in_group("Appartement")
	for appartement in appartements_groupe:
		if appartement is Appartement:
			appartements_array.append(appartement)
			
## prob need to randomize after each call
func get_free_appartement() -> Appartement:
	for appartement in appartements_array:
		if appartement.free_space > 0: return appartement
	return null
