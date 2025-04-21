extends Node
class_name InteractionRay

const META_INTERACTABLE := "interactable"


@export var camera : Camera3D = null
@export var interact_distance : float = 2
var interact_timer := 0.0
var interact_body : Node3D = null

@onready var hud : HUD = HudManager.hud
@onready var player : Player = EntityManager.player





func _ready() -> void:
	assert(camera)

func interact_cast() -> Node3D:
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = camera.get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var end = origin + camera.project_ray_normal(screen_center) * interact_distance
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_bodies = true
	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return null
	
	return result["collider"]
	

func _physics_process(delta: float) -> void:
		var collider := interact_cast()
		if collider == interact_body:
			if collider == null and not hud.is_crossair():
				player.set_interaction(null)
			return

		if collider == null or !collider.has_meta(META_INTERACTABLE):
			interact_body = null
			player.set_interaction(null)
			return
		
		interact_body = collider
		var interaction : Interactable = interact_body.get_meta(META_INTERACTABLE)
		player.set_interaction(interaction)

		
