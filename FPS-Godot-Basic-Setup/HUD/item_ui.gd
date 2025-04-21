extends TextureRect
class_name ItemUI

@export var item : ItemData = null
@onready var quantity: Label = $Quantity
@onready var local_index_label: Label = $Local_index_label

@onready var panel: Panel = $Panel


const SELECTED_STYLE = preload("res://HUD/selected_style.tres")
const DEFAULT_STYLE = preload("res://HUD/default_style.tres")

var local_index : int = 0

func _ready() -> void:
	if item:
		texture = item.icon


func _get_drag_data(at_position: Vector2) -> ItemData:
	if item == null: return
	
	var preview_texture := TextureRect.new()
	preview_texture.texture = item.icon
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(75, 75)
	var preview = Control.new()
	preview.add_child(preview_texture)
	set_drag_preview(preview)
	
	return item
	
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is ItemData
	
	
func _drop_data(at_position: Vector2, data: Variant) -> void:
	item = data
	texture = item.icon
	
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
