extends Node

const POLYGON_DEFAULT = preload("res://Assets/PolygonShops_Texture_01_A.png")
const POLYGON_A = preload("res://Assets/PolygonShops_Texture_01_B.png")
const POLYGON_B = preload("res://Assets/PolygonShops_Texture_01_C.png")
const POLYGON_C = preload("res://Assets/PolygonShops_Texture_02_A.png")
const POLYGON_D = preload("res://Assets/PolygonShops_Texture_02_B.png")
const POLYGON_E = preload("res://Assets/PolygonShops_Texture_02_C.png")
const POLYGON_F = preload("res://Assets/PolygonShops_Texture_03_A.png")
const POLYGON_G = preload("res://Assets/PolygonShops_Texture_03_B.png")
const POLYGON_H = preload("res://Assets/PolygonShops_Texture_03_C.png")
const POLYGON_I = preload("res://Assets/PolygonShops_Texture_04_A.png")
const POLYGON_J = preload("res://Assets/PolygonShops_Texture_04_B.png")
const POLYGON_K = preload("res://Assets/PolygonShops_Texture_04_C.png")

var polygon_texture_array: Array[Texture2D] = []

func _ready() -> void:
	polygon_texture_array = [
		POLYGON_DEFAULT,
		POLYGON_A,
		POLYGON_B,
		POLYGON_C,
		POLYGON_D,
		POLYGON_E,
		POLYGON_F,
		POLYGON_G,
		POLYGON_H,
		POLYGON_I,
		POLYGON_J,
		POLYGON_K
	]
