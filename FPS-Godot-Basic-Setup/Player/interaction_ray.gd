extends Node
class_name InteractionRay

const META_INTERACTABLE := "interactable"


@export var camera : Camera3D = null
@export var interact_distance : float = 2
var interact_timer := 0.0
var interact_body : Node3D = null

@onready var hud : HUD = HudManager.hud
@onready var player : Player = EntityManager.player

var last_ray_result: Dictionary = {}




func _ready() -> void:
	assert(camera)

func interact_cast(distance: float = interact_distance) -> Dictionary:
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = camera.get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return {}
	return result
	

func _physics_process(_delta: float) -> void:
	last_ray_result = interact_cast()

	if last_ray_result.is_empty():
		if interact_body != null and not hud.is_crossair():
			player.set_interaction(null)
		interact_body = null
		return

	var collider: Node3D = last_ray_result["collider"]

	if collider == interact_body:
		if collider == null and not hud.is_crossair():
			player.set_interaction(null)
		return

	if collider == null or not collider.has_meta(META_INTERACTABLE):
		interact_body = null
		player.set_interaction(null)
		return

	interact_body = collider
	var interaction: Interactable = interact_body.get_meta(META_INTERACTABLE)
	player.set_interaction(interaction)

		
