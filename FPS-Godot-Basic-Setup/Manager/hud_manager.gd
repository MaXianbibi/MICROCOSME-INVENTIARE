extends Node

@onready var hud : HUD = get_tree().get_first_node_in_group("HUD")
@onready var player_item_hud: PlayerUI = get_tree().get_first_node_in_group("PlayerUI")
@onready var sub_menu_hud : SubItemMenu = get_tree().get_first_node_in_group("SubMenuHud")
