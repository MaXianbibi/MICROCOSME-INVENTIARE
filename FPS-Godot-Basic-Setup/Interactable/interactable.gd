extends Node
class_name Interactable


@onready var parent : PhysicsBody3D = get_parent()
@onready var player : Player = EntityManager.player

var key := "E"
var interaction_name = "Do nothing"
var _name := ""
var hud : HUD = HudManager.hud


func interact(body : Entity = null) -> void:
	push_error("Not supposed to be interact with")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(parent)
	
	
	var interactionMeta = null
	
	if parent.has_meta("interactable"):
		interactionMeta = parent.get_meta("interactable", null)
	if interactionMeta == null or interactionMeta is Movable:		
		parent.set_meta("interactable", self)
	
	init()

func init() -> void:
	pass
	
func hide_object() -> void:
	parent.hide()
	
func show_object() -> void:
	parent.show()
