extends TextureRect
class_name ItemUI

@export var item : ItemData = null
@onready var quantity: Label = $Quantity
@onready var local_index_label: Label = $Local_index_label
@onready var panel: Panel = $Panel

@onready var player : Player = EntityManager.player
@onready var sub_menu : SubItemMenu = HudManager.sub_menu_hud

const SELECTED_STYLE = preload("res://HUD/selected_style.tres")
const DEFAULT_STYLE = preload("res://HUD/default_style.tres")

var local_index : int = 0
var is_sub_menu : bool = true


func _ready() -> void:
	if item:
		texture = item.icon


func _get_drag_data(_at_position: Vector2) -> Dictionary:
	if item == null: return {}
		
	var preview_texture := TextureRect.new()
	preview_texture.texture = item.icon
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(75, 75)
	var preview = Control.new()
	preview.add_child(preview_texture)
	set_drag_preview(preview)
	
	var drag_data := {
	"item": item,
	"local_index": local_index,
	"is_sub_menu": is_sub_menu  # ← cette variable existe déjà dans ItemUI
	}

	
	return drag_data
	
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("item")
	
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	
	var from_sub: bool = data.get("is_sub_menu", false)
	var to_sub := is_sub_menu
	
	var item : ItemData = data.get("item", null)
	if item == null: return
	
	match [from_sub, to_sub]:
		[true, true]:
			sub_menu.sub_inventory.swap_item(item.local_index, local_index)
		[true, false]:
			sub_menu.sub_inventory.remove_single_item(item.local_index)
			player.inventory.add_single_item(item, local_index)
		[false, true]:
			player.inventory.remove_single_item(item.local_index)
			sub_menu.sub_inventory.add_single_item(item, local_index)
			
		[false, false]:
			player.inventory.swap_item(item.local_index, local_index)
	
	player.updateUI()
	sub_menu._update()
	
	

		
func update() -> void:
	if item == null: 
		texture = null
		quantity.text = ""
		return
		
	texture = item.icon
	quantity.text = str(item.size)
	
	
func select() -> void:
	panel.add_theme_stylebox_override("panel", SELECTED_STYLE)

func unselect() -> void:
	panel.add_theme_stylebox_override("panel", DEFAULT_STYLE)
