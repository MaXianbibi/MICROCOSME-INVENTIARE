extends Interactable
class_name OpenDoor


@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var timer: Timer = %Timer

var is_open : bool = false
var is_in_animation : bool = false

var open_front : bool = false


func init() -> void:
	_name = "Door"
	interaction_name = "open the "
	key = "E"
	
	assert(animation_player.has_animation("Open"))
	assert(animation_player.has_animation("OpenBack"))
	
	timer.timeout.connect(_on_timer_timeout)
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	
	


func interact(body: Entity = null) -> void:
	if is_in_animation: return
	
	var door_forward: Vector3 = parent.global_transform.basis.z.normalized()
	var player_direction: Vector3 = (body.global_transform.origin - parent.global_transform.origin).normalized()
	var dot: float = door_forward.dot(player_direction)

	if dot > 0.0:
		if is_open:
			animation_player.play_backwards("OpenBack")
			timer.stop()
			is_open = false
		else:
			animation_player.play("OpenBack")
			timer.start()
			is_open = true
			open_front = false
	else:
		if is_open:
			animation_player.play_backwards("Open")
			timer.stop()
			is_open = false
		else:
			animation_player.play("Open")
			timer.start()
			open_front = true
			is_open = true

	is_in_animation = true

func _on_timer_timeout() -> void:
	if open_front:
		animation_player.play_backwards("Open")
	else:
		animation_player.play_backwards("OpenBack")		
			
			
	is_open = false
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	is_in_animation = false
