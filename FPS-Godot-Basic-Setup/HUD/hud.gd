extends Control
class_name HUD

@onready var crossair : Panel = $Crossair
@onready var interaction_label : InteractionLabel = $InteractionLabel
@onready var time_of_day: Label = $TimeOfDay

func show_crossair() -> void:
	interaction_label.hide()
	crossair.show()

func show_interaction_label(key: String, interaction: String, _name: String) -> void:
	interaction_label.set_interaction(key, interaction, _name)
	
	crossair.hide()
	interaction_label.show()
	
func is_crossair() -> bool:
	return crossair.visible

func update_time(time: float) -> void:
	var hours = int(time)
	var minutes = int((time - hours) * 60)

	var formatted_time = "%02d:%02d" % [hours, minutes]
	time_of_day.text = formatted_time
