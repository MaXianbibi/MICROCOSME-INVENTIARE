extends Control
class_name HUD

@onready var crossair : Panel = $Crossair
@onready var interaction_label : InteractionLabel = $InteractionLabel

func show_crossair() -> void:
	interaction_label.hide()
	crossair.show()

func show_interaction_label(key: String, interaction: String, _name: String) -> void:
	interaction_label.set_interaction(key, interaction, _name)
	
	crossair.hide()
	interaction_label.show()
	
func is_crossair() -> bool:
	return crossair.visible
