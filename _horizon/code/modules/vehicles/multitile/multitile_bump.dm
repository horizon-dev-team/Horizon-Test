/obj/vehicle/multitile/Collide(atom/A)
	if(A && !QDELETED(A))
		if(istype(A, /mob/living))
			var/mob/living/L = A
			L.last_bumped = world.time
		A.Collided(src)
	return A.handle_vehicle_bump(src)


//-----------------MAIN BUMP HANDLING PROC-------------------

/atom/proc/handle_vehicle_bump(obj/vehicle/multitile/V)
	return FALSE

//-----------------------------------------------------------
//-------------------------TURFS-----------------------------
//-----------------------------------------------------------


/turf/closed/wall/handle_vehicle_bump(obj/vehicle/multitile/V)
	if(!(turf_flags & TURF_HULL) && !(V.vehicle_flags & VEHICLE_CLASS_WEAK))
		take_damage(V.wall_ram_damage)
		V.take_damage_type(10, "blunt", src)
		playsound(V, 'sound/effects/metal_crash.ogg', 35)
		visible_message(span_danger("\The [V] rams \the [src]!"))
	return FALSE

//-----------------------------------------------------------
//-------------------------OBJECTS---------------------------
//-----------------------------------------------------------

/obj/handle_vehicle_bump(obj/vehicle/multitile/V)
	if(!(resistance_flags & UNACIDABLE))
		V.take_damage_type(5, "blunt", src)
		visible_message(span_danger("\The [V] crushes [src]!"))
		playsound(V, 'sound/effects/metal_crash.ogg', 20)
		qdel(src)
	return FALSE

//-------------------------STRUCTURES------------------------

/obj/structure/handle_vehicle_bump(obj/vehicle/multitile/V)
	visible_message(span_danger("\The [V] crushes \the [src]!"))
	playsound(V, 'sound/effects/metal_crash.ogg', 20)
	qdel(src)
	if(V.vehicle_flags & VEHICLE_CLASS_MEDIUM || V.vehicle_flags & VEHICLE_CLASS_HEAVY)
		return TRUE
	return FALSE

// XENO REMOVED: /obj/structure/barricade/handle_vehicle_bump — CM13 barricade types
// XENO REMOVED: /obj/structure/alien/movable_wall/handle_vehicle_bump
// XENO REMOVED: /obj/structure/mortar/handle_vehicle_bump

/obj/structure/window/handle_vehicle_bump(obj/vehicle/multitile/V)
	take_damage(V.wall_ram_damage)
	visible_message(span_danger("\The [V] rams \the [src]!"))
	return TRUE

// XENO REMOVED: All CM13-specific machinery types (cm_vending, m56d_post, m56d_hmg, defenses/sentry, etc.)
// TG machinery is under /obj/machinery/ not /obj/structure/machinery/

/obj/structure/grille/handle_vehicle_bump(obj/vehicle/multitile/V)
	if(!(V.vehicle_flags & VEHICLE_CLASS_MEDIUM || V.vehicle_flags & VEHICLE_CLASS_HEAVY))
		V.move_momentum -= V.move_momentum * 0.5
	visible_message(span_danger("\The [V] crushes \the [src]!"))
	playsound(src, 'sound/effects/grillehit.ogg', 20)
	qdel(src)
	return TRUE

/obj/structure/inflatable/handle_vehicle_bump(obj/vehicle/multitile/V)
	if(V.vehicle_flags & VEHICLE_CLASS_WEAK)
		V.move_momentum -= V.move_momentum * 0.5
	visible_message(span_danger("\The [V] rams \the [src]!"))
	density = FALSE
	deflate(TRUE)
	return TRUE

/obj/structure/flora/tree/handle_vehicle_bump(obj/vehicle/multitile/V)
	if(V.vehicle_flags & VEHICLE_CLASS_WEAK)
		return FALSE
	else if(V.vehicle_flags & VEHICLE_CLASS_LIGHT)
		V.move_momentum -= V.move_momentum * 0.5

	visible_message(span_danger("\The [V] crushes \the [src]!"))
	playsound(src, 'sound/effects/metal_crash.ogg', 20)
	playsound(src, 'sound/effects/woodhit.ogg', 20)
	qdel(src)
	return TRUE

//-------------------------VEHICLES------------------------

/obj/vehicle/handle_vehicle_bump(obj/vehicle/multitile/V)
	V.take_damage_type(5, "blunt", V)
	take_damage(-round(-(max_integrity/2.8))) //we destroy any simple vehicle in 3 crushes

	visible_message(span_danger("\The [V] crushes into \the [src]!"))
	playsound(V, 'sound/effects/metal_crash.ogg', 35)
	return FALSE

/obj/vehicle/multitile/handle_vehicle_bump(obj/vehicle/multitile/V)
	var/damage

	if(last_move_dir == REVERSE_DIR(V.last_move_dir)) //crashing into each other
		damage = move_momentum + V.move_momentum
	else if(last_move_dir == V.last_move_dir) //crashing into something from behind
		damage = max(V.move_momentum - move_momentum, 0)
	else
		damage = V.move_momentum

	damage = 5 * (damage + 1) //5 is minimal damage of bumping which is multiplied on vehicles' current momentum.
	if(V.vehicle_flags & VEHICLE_CLASS_WEAK)
		V.take_damage_type(TIER_3_RAM_DAMAGE_TAKEN, "blunt", src)
	else
		V.take_damage_type(damage, "blunt", src)

	if(vehicle_flags & VEHICLE_CLASS_WEAK)
		take_damage_type(TIER_3_RAM_DAMAGE_TAKEN, "blunt", V)
	else
		take_damage_type(damage, "blunt", V)

	visible_message(span_danger("\The [V] crushes into \the [src]!"))
	playsound(V, 'sound/effects/metal_crash.ogg', 35)
	return FALSE

//-----------------------------------------------------------
//-------------------------MOBS------------------------------
//-----------------------------------------------------------

/mob/living/handle_vehicle_bump(obj/vehicle/multitile/V)
	if(is_mob_incapacitated(src, TRUE))
		apply_damage(7 + rand(0, 5), BRUTE)
		return TRUE

	var/mob/living/driver = V.get_seat_mob(VEHICLE_DRIVER)
	var/dmg = FALSE
	if(V.vehicle_flags & VEHICLE_CLASS_WEAK)
		if(driver && get_target_lock(driver.faction))
			apply_effect(0.5, EFFECT_KNOCKDOWN)
		else
			apply_effect(1, EFFECT_KNOCKDOWN)

	else if(V.vehicle_flags & VEHICLE_CLASS_LIGHT)
		if(get_target_lock(driver?.faction))
			apply_effect(0.5, EFFECT_KNOCKDOWN)
		else
			apply_effect(2, EFFECT_KNOCKDOWN)
			apply_damage(5 + rand(0, 10), BRUTE)
			dmg = TRUE

	else if(V.vehicle_flags & VEHICLE_CLASS_MEDIUM)
		apply_effect(3, EFFECT_KNOCKDOWN)
		apply_damage(10 + rand(0, 10), BRUTE)
		dmg = TRUE

	else if(V.vehicle_flags & VEHICLE_CLASS_HEAVY)
		apply_effect(5, EFFECT_KNOCKDOWN)
		apply_damage(15 + rand(0, 10), BRUTE)
		dmg = TRUE

	var/list/slots = V.get_activatable_hardpoints()
	for(var/slot in slots)
		var/obj/item/hardpoint/H = V.hardpoints[slot]
		if(!H)
			continue
		H.livingmob_interact(src)

	apply_effect(3, EFFECT_KNOCKDOWN)
	apply_damage(7 + rand(0, 5), BRUTE)
	var/mob_moved = step(src, V.last_move_dir)

	visible_message(span_danger("\The [V] rams \the [src]!"), span_danger("\The [V] rams you! Get out of the way!"))
	if(dmg)
		playsound(loc, 'sound/weapons/punch1.ogg', 25, TRUE)
		log_attack("[key_name(src)] was rammed by [key_name(driver)] with [V].")
		if(driver && faction == driver.faction)
			msg_admin_ff("[key_name(driver)] rammed [key_name(src)] with \the [V] in [get_area(src)]", TRUE, loc.z)
	else
		log_attack("[key_name(src)] was friendly pushed by [key_name(driver)] with [V].")

	return mob_moved

//-------------------------HUMANS------------------------

/mob/living/carbon/human/handle_vehicle_bump(obj/vehicle/multitile/V)
	var/mob/living/driver = V.get_seat_mob(VEHICLE_DRIVER)
	var/dmg = FALSE

	var/mob_moved = FALSE
	var/mob_knocked_down = is_mob_incapacitated(src)

	if(V.vehicle_flags & VEHICLE_CLASS_WEAK)
		if(!mob_knocked_down)
			var/direction_taken = pick(45, 0, -45)
			mob_moved = step(src, turn(V.last_move_dir, direction_taken))
			if(!mob_moved)
				mob_moved = step(src, turn(V.last_move_dir, -direction_taken))
	else if(V.vehicle_flags & VEHICLE_CLASS_LIGHT)
		dmg = TRUE
		if(get_target_lock(driver?.faction))
			apply_effect(0.5, EFFECT_KNOCKDOWN)
			apply_damage(5 + rand(0, 5), BRUTE)
			to_chat(V.seats[VEHICLE_DRIVER], span_warning(span_bold("*YOU RAMMED AN ALLY AND HURT THEM!*")))
		else
			apply_effect(2, EFFECT_KNOCKDOWN)
			apply_damage(10 + rand(0, 10), BRUTE)

	else if(V.vehicle_flags & VEHICLE_CLASS_MEDIUM)
		apply_effect(3, EFFECT_KNOCKDOWN)
		apply_damage(10 + rand(0, 10), BRUTE)
		dmg = TRUE

	else if(V.vehicle_flags & VEHICLE_CLASS_HEAVY)
		apply_effect(5, EFFECT_KNOCKDOWN)
		apply_damage(15 + rand(0, 10), BRUTE)
		dmg = TRUE

	visible_message(span_danger("\The [V] rams \the [src]!"), span_danger("\The [V] rams you! Get out of the way!"))
	if(dmg)
		playsound(loc, 'sound/weapons/punch1.ogg', 25, TRUE)
		log_attack("[key_name(src)] was rammed by [key_name(driver)] with [V].")
		if(driver && faction == driver.faction)
			msg_admin_ff("[key_name(driver)] rammed and damaged member of allied faction [key_name(src)] with \the [V] in [get_area(src)]", TRUE, loc.z)
	else
		log_attack("[key_name(src)] was friendly pushed by [key_name(driver)] with [V].")

	if(mob_knocked_down)
		return TRUE
	else if (mob_moved)
		playsound(loc, 'sound/weapons/punch1.ogg', 25, TRUE)

	return TRUE

//-------------------------XENOS------------------------
// XENO REMOVED: All xenomorph handle_vehicle_bump overrides commented out.
// /mob/living/carbon/xenomorph/handle_vehicle_bump — REMOVED
// /mob/living/carbon/xenomorph/burrower/handle_vehicle_bump — REMOVED
// /mob/living/carbon/xenomorph/defender/handle_vehicle_bump — REMOVED

// CRUSHER CHARGE COLLISION
// XENO REMOVED: /obj/vehicle/multitile/Collided — references iscrusher(), CM13 xeno type
// /obj/vehicle/multitile/Collided(atom/A) — REMOVED (xeno crusher logic)
