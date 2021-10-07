extends Area2D

func is_colliding():
	var areas = get_overlapping_bodies()
	return areas.size() > 0
