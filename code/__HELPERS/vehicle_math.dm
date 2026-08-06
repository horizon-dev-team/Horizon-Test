// Math helpers for multitile vehicles, ported from CM13

/// Returns the angle difference between dirs a and b (positive = clockwise)
/proc/turning_angle(a, b)
	return -(dir2angle(b) - dir2angle(a))

/// Returns a list of turfs in a rectangle from the corner turf
#define CORNER_BLOCK(corner, width, height) CORNER_BLOCK_OFFSET(corner, width, height, 0, 0)

/// Returns a list of turfs in a rectangle from corner with offset
#define CORNER_BLOCK_OFFSET(corner, width, height, offset_x, offset_y) \
	block(\
		locate(corner.x + offset_x, corner.y + offset_y, corner.z),\
		locate(corner.x + offset_x + width - 1, corner.y + offset_y + height - 1, corner.z)\
	)

/// Rotates a point (given as list[x, y]) around a center point (list[x, y]) by deg degrees.
/// Ported from CM13's RotateAroundAxis.
/proc/RotateAroundAxis(list/point, list/center, deg)
	var/cos_theta = cos(deg)
	var/sin_theta = sin(deg)
	var/dx = point[1] - center[1]
	var/dy = point[2] - center[2]
	return list(
		center[1] + dx * cos_theta - dy * sin_theta,
		center[2] + dx * sin_theta + dy * cos_theta
	)

// floor() and ceil() are reserved words in TG — use FLOOR/CEIL macros or round() instead.
// get_offset_target_turf already exists in code/__HELPERS/turfs.dm — removed duplicate.

/// Returns the turf at a given angle and range from the source turf.
/proc/get_angle_target_turf(turf/source, angle, range)
	if(!source)
		return null
	var/target_x = source.x + sin(angle) * range
	var/target_y = source.y + cos(angle) * range
	return locate(round(target_x), round(target_y), source.z)


/// Called when a movable atom has hit an atom via movement
/atom/movable/proc/Collide(atom/A)
	if (throwing)
		launch_impacts(A)

	if (A && !QDELETED(A))
		//A.last_bumped = world.time
		A.Collided(src)

#define COMSIG_STRUCTURE_COLLIDED "structure_collided"

/atom/proc/Collided(atom/movable/AM)
	return

/// Called when an atom has been hit by a movable atom via movement
/atom/movable/Collided(atom/movable/collider)
	if(!anchored && isliving(collider))
		var/target_dir = get_dir(collider, src)
		var/turf/target_turf = get_step(loc, target_dir)
		Move(target_turf)


//called when src is thrown into hit_atom
/atom/movable/proc/launch_impacts(atom/hit_atom)
	if (isliving(hit_atom))
		mob_launch_collision(hit_atom)
	else if (isobj(hit_atom)) // Thrown object hits another object and moves it
		obj_launch_collision(hit_atom)
	//else if (isturf(hit_atom))
	//	var/turf/T = hit_atom
	//	if (T.density)
	//		turf_launch_collision(T)

	throwing = FALSE
	//rebounding = FALSE

/atom/movable/proc/mob_launch_collision(mob/living/L)
	//if (!rebounding)
	//	L.hitby(src)
	L.hitby(src)

/atom/movable/proc/obj_launch_collision(obj/O)
	if (!O.anchored)
		O.Move(get_step(O, dir))
	//else if (!rebounding && rebounds)
	//	var/oldloc = loc
	//	var/launched_speed = cur_speed
	//	addtimer(CALLBACK(src, PROC_REF(rebound), oldloc, launched_speed), 0.5)

	//if (!rebounding)
	//	O.hitby(src)

/*
/atom/movable/proc/turf_launch_collision(turf/T)
	if (!rebounding && rebounds)
		var/oldloc = loc
		var/launched_speed = cur_speed
		addtimer(CALLBACK(src, PROC_REF(rebound), oldloc, launched_speed), 0.5)

	if (!rebounding)
		T.hitby(src)
*/
