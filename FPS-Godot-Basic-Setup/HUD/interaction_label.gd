extends HBoxContainer
class_name InteractionLabel


@onready var key : Label = $Key
@onready var interaction : Label = $Interaction
@onready var _name : Label = $Name
 

func set_interaction(new_key : String, new_interaction : String, new_name: String) -> void:
	key.text = new_key
	interaction.text = new_interaction
	_name.text = new_name
	
