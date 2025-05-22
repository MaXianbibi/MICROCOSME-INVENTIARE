extends Interactable

func init() -> void:
	interaction_name = " to start working"


func interact(body : Entity = null) -> void:
	print("start working")
