extends Node
class_name Interactable


@onready var parent : PhysicsBody3D = get_parent()

var player : Player = EntityManager.player
var key := "E"
var interaction_name = "Do nothing"
var _name := "nothing"
var hud : HUD = HudManager.hud

func interact() -> void:
	push_error("Not supposed to be interact with")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(parent)
	parent.set_meta("interactable", self)
	init()

func init() -> void:
	pass
	
func hide_object() -> void:
	parent.hide()
	
func show_object() -> void:
	parent.show()
