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


const OUTLINE = preload("res://Object/OutlineShader/Outline.gdshader")
var selected_shader : ShaderMaterial

var polygon_texture_array: Array[Texture2D] = []
var polygon_material_array: Array[StandardMaterial3D] = []


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

	for texture in polygon_texture_array:
		var mat := StandardMaterial3D.new()
		mat.albedo_texture = texture
		mat.metallic = 0.0
		mat.roughness = 1.0
		polygon_material_array.append(mat)
		
	selected_shader = ShaderMaterial.new()
	selected_shader.shader = OUTLINE
		
func get_default_material() -> StandardMaterial3D:
	return polygon_material_array[0]
	
	
func get_select_static_shader() -> ShaderMaterial:
	return selected_shader
