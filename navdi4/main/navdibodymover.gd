extends Node2D
class_name NavdiBodyMover

#enum { HORIZONTAL, VERTICAL, } # axes already default godot consts!

func cast_best_snap_dir(body : Node2D, caster : ShapeCast2D, axis, movement_amount : float) -> int:
	var scoreStay = cast_fraction(body,caster,axis,movement_amount,0)
	if scoreStay >= 1: return 0
	var scoreMinus = cast_fraction(body,caster,axis,movement_amount,-1)
	var scorePlus = cast_fraction(body,caster,axis,movement_amount,1)
	if scoreMinus > scoreStay:
		if scoreMinus > scorePlus: return -1
		elif scorePlus > scoreMinus: return 1
		else: return (-1) if randf()<0.5 else (1)
	elif scorePlus > scoreStay:
		return 1
	else:
		return 0

func cast_fraction(body : Node2D, caster : ShapeCast2D, axis, movement_amount : float, snap_dir : int = 0) -> float:
	caster.position = Vector2.ZERO
	caster.target_position = Vector2.ZERO
	match axis:
		HORIZONTAL:
			caster.target_position.x = movement_amount
			caster.position.y += snapp_rel(body.position.y, snap_dir)
		VERTICAL:
			caster.target_position.y = movement_amount
			caster.position.x += snapp_rel(body.position.x, snap_dir)
	caster.force_shapecast_update()
	return caster.get_closest_collision_safe_fraction()

func move(body : Node2D, axis, movement_amount : float = 0.0, snap_dir : int = 0):
	match axis:
		HORIZONTAL:
			body.position.x += movement_amount
			if snap_dir: body.position.y = snapp(body.position.y, snap_dir)
		VERTICAL:
			body.position.y += movement_amount
			if snap_dir: body.position.x = snapp(body.position.x, snap_dir)

func try_slip_move(body : Node2D, caster : ShapeCast2D, axis, movement_amount : float) -> bool:
	var snap_dir = cast_best_snap_dir(body, caster, axis, movement_amount)
	var fraction = cast_fraction(body, caster, axis, movement_amount, snap_dir)
	if fraction < 1.0: movement_amount *= fraction
	if fraction > 0.001: move(body, axis, movement_amount, snap_dir)
	return fraction >= 1.0

func snapp(value : float, snap_dir : int) -> float:
	if snap_dir == 0: return value
	if value != roundf(value):
		if snap_dir < 0: snap_dir += 1; value = floori(value)
		if snap_dir > 0: snap_dir -= 1; value = ceili(value)
	return value + snap_dir

func snapp_rel(value : float, snap_dir : int) -> float:
	return snapp(value, snap_dir) - value
