extends Interactable
class_name WorkingStation

@export var next_client : Marker3D = null

func init() -> void:
	assert(next_client)
	interaction_name = " to start working"


func interact(body : Entity = null) -> void:
	print("start working")

func get_next_client_spot() -> Marker3D:
	return next_client
