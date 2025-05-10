extends Node

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var stores_array : Array[Store] = []

func _ready() -> void:
	var store_groupes = get_tree().get_nodes_in_group("Stores")
	for store in store_groupes:
		if store is Store:
			stores_array.append(store)
