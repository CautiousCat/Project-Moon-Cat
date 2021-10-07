extends Camera2D

onready var Player = get_tree().get_nodes_in_group("Player")

export var smoothing = 0.6

func _physics_process(delta):
	global_position = Player[0].global_position
	print(global_position)
