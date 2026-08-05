
// Special cases abound, handled below or in subclasses
/obj/vehicle/multitile/attackby(obj/item/O, mob/user)
	// Are we trying to install stuff?
	if(istype(O, /obj/item/hardpoint))
		var/obj/item/hardpoint/HP = O
		install_hardpoint(HP, user)
		return

	// XENO REMOVED: powerloader clamp logic
	// if(ispowerclamp(O))
	//      ...

	// Are we trying to remove stuff?
	if(iscrowbar(O))
		uninstall_hardpoint(O, user)
		return

	// Are we trying to repair the frame?
	if(iswelder(O) || iswrench(O))
		handle_repairs(O, user)
		return

	// Are we trying to immobilize the vehicle?
	if(istype(O, /obj/item/vehicle_clamp))
		if(clamped)
			to_chat(user, span_warning("[src] already has a [O.name] attached."))
			return

		if(!skillcheck(user, SKILL_POLICE, SKILL_POLICE_SKILLED))
			to_chat(user, span_warning("You don't know how to use \the [O.name]."))
			return

		for(var/obj/item/hardpoint/locomotion/Loco in hardpoints)
			user.visible_message(span_warning("[user] attaches the vehicle clamp to \the [src]."), span_notice("You attach the vehicle clamp to \the [src] and lock the mechanism."))
			attach_clamp(O, user)
			return

		to_chat(user, span_warning("There are no treads or wheels to attach \the [O.name] to."))
		return

	// Are we trying to remove a vehicle clamp?
	if(isscrewdriver(O))
		if(!clamped)
			return

		user.visible_message(span_warning("[user] starts removing the vehicle clamp from [src]."), span_notice("You start removing the vehicle clamp from [src]."))
		if(skillcheck(user, SKILL_POLICE, SKILL_POLICE_SKILLED))
			if(!cm_do_after(user, 2 SECONDS, src, INTERRUPT_ALL))
				user.visible_message(span_warning("[user] stops removing the vehicle clamp from [src]."), span_warning("You stop removing the vehicle clamp from [src]."))
				return
			user.visible_message(span_warning("[user] swiftly removes the vehicle clamp from [src]."), span_notice("You skillfully unlock the mechanism and swiftly remove the vehicle clamp from [src]."))
		else
			if(!cm_do_after(user, 5 SECONDS, src, INTERRUPT_ALL))
				user.visible_message(span_warning("[user] stops removing the vehicle clamp from [src]."), span_warning("You stop removing the vehicle clamp from [src]."))
				return
			user.visible_message(span_warning("[user] clumsily removes the vehicle clamp from [src]."), span_notice("You manage to unlock vehicle clamp and take it off [src]."))
		detach_clamp(user)
		return

/*
	//try to fit something in vehicle without getting in ourselves
	if(istype(O, /obj/item/grab) && ishuman(user)) //only humans are allowed to fit dragged stuff inside
		if(user.a_intent == INTENT_HELP)
			var/mob_x = user.x - src.x
			var/mob_y = user.y - src.y
			for(var/entrance in entrances)
				var/entrance_coord = entrances[entrance]
				if(mob_x == entrance_coord[1] && mob_y == entrance_coord[2])
					var/obj/item/grab/G = O
					var/atom/dragged_atom = G.affecting
					handle_fitting_pulled_atom(user, dragged_atom)
					return
		else
			to_chat(user, span_info("Use [span_nicegreen("HELP")] intent to put a pulled object or creature into the vehicle without getting inside yourself."))
			handle_player_entrance(user)
			return
*/

	// XENO REMOVED: grenade throwing logic (CM13-specific grenade type)
	// if(istype(O, /obj/item/explosive/grenade))
	//      ...

	// XENO REMOVED: motion detector scanning (CM13-specific device)
	// if(istype(O, /obj/item/device/motiondetector))
	//      ...

	if(user.a_intent != INTENT_HARM)
		handle_player_entrance(user)
		return

	take_damage_type(O.force * 0.05, "blunt", user) //Melee weapons from people do very little damage

// Frame repairs on the vehicle itself
/obj/vehicle/multitile/proc/handle_repairs(obj/item/O, mob/user)
	// CM13 used `user.action_busy` here to bail out if a repair was already in
	// progress. TG has no `action_busy` var; TG's `do_after` (which
	// `cm_do_after` bridges to) tracks busy state internally and returns FALSE
	// if the user is already busy, so the early-out is no longer needed —
	// the while-loop below will simply exit on its first iteration instead.
	var/max_hp = max_integrity
	if(get_integrity() > max_hp)
		update_integrity(max_hp)
		to_chat(user, span_notice("The hull is fully intact."))
		for(var/obj/item/hardpoint/holder/H in hardpoints)
			if(H.get_integrity() > 0)
				if(!iswelder(O))
					to_chat(user, span_warning("You need welding tool to repair \the [H.name]."))
					return
				H.handle_repair(O, user)
				update_icon()
				return
			else
				to_chat(user, span_warning("[H] is beyond repairs!"))
				return

	var/repair_message = "welding structural struts back in place"
	var/sound_file = 'sound/items/welder.ogg'

	// For health < 75%, the frame needs welderwork, otherwise wrench
	if(get_integrity() < max_hp * 0.75)
		if(!iswelder(O))
			to_chat(user, span_notice("The frame is way too busted! Try using a [span_nicegreen("welder")]."))
			return

		var/obj/item/weldingtool/WT = O
		if(!WT.tool_start_check(user, amount=1))
			to_chat(user, span_warning("\The [WT] needs to be on and have fuel!"))
			return

	else
		if(!iswrench(O))
			to_chat(user, span_notice("The frame is structurally sound, but there are a lot of loose nuts and bolts. Try using a [span_nicegreen("wrench")]."))
			return

		repair_message = "tightening various nuts and bolts on"
		sound_file = 'sound/items/ratchet.ogg'

	var/amount_fixed_adjustment = user.get_skill_duration_multiplier(SKILL_ENGINEER)
	user.visible_message(span_warning("[user] [repair_message] on \the [src]."), span_notice("You begin [repair_message] on \the [src]."))
	playsound(get_turf(user), sound_file, 25)

	while(get_integrity() < max_hp)
		if(!(world.time % 3))
			playsound(get_turf(user), sound_file, 25)

		if(!cm_do_after(user, 1 SECONDS, src, INTERRUPT_ALL))
			user.visible_message(span_warning("[user] stops [repair_message] on \the [src]."), span_notice("You stop [repair_message] on \the [src]. Hull integrity is at [span_nicegreen(100.0*get_integrity()/max_hp)]%."))
			return

		update_integrity(min(get_integrity() + max_hp/100 * (5 / amount_fixed_adjustment), max_hp))
		if(lighting_holder && !lighting_holder.light_range)
			update_minimap_icon()
			lighting_holder.set_light_on(TRUE)

		if(istype(O, /obj/item/weldingtool))
			var/obj/item/weldingtool/WT = O
			WT.use_tool(src, user, 0, amount=1)
			if(WT.get_fuel() < 1)
				user.visible_message(span_warning("[user] stops [repair_message] on \the [src]."), span_notice("You stop [repair_message] on \the [src]. Hull integrity is at [span_nicegreen(100.0*get_integrity()/max_hp)]%."))
				return
			if(get_integrity() >= max_hp * 0.75)
				user.visible_message(span_warning("[user] finishes [repair_message] on \the [src]."), span_notice("You finish [repair_message] on \the [src]. The frame is structurally sound now, but there are a lot of loose nuts and bolts. Try using a [span_nicegreen("wrench")]."))
				return

		to_chat(user, span_notice("Hull integrity is at [span_nicegreen(100.0*get_integrity()/max_hp)]%."))

	update_integrity(max_integrity)
	lighting_holder.set_light_range(vehicle_light_range)
	toggle_cameras_status(TRUE)
	update_icon()
	user.visible_message(span_notice("[user] finishes [repair_message] on \the [src]."), span_notice("You finish [repair_message] on \the [src]. Hull integrity is at [span_nicegreen(100.0*get_integrity()/max_hp)]%."))
	return

//Special case for entering the vehicle without using the verb
/obj/vehicle/multitile/attack_hand(mob/user)
	var/mob_x = user.x - src.x
	var/mob_y = user.y - src.y
	for(var/entrance in entrances)
		var/entrance_coord = entrances[entrance]
		if(mob_x == entrance_coord[1] && mob_y == entrance_coord[2])
			handle_player_entrance(user)
			return
	. = ..()

/obj/vehicle/multitile/attack_ghost(mob/dead/observer/user)
	if(!interior)
		return ..()

	var/turf/middle = interior.get_middle_turf()
	if(!middle)
		return ..()

	user.forceMove(middle)

// XENO REMOVED: /obj/vehicle/multitile/attack_alien — entire proc commented out
// /obj/vehicle/multitile/attack_alien(mob/living/carbon/xenomorph/X)
//      ...

//Differentiates between damage types from different bullets
//Applies a linear transformation to bullet damage that will generally decrease damage done
/obj/vehicle/multitile/bullet_act(obj/projectile/P)
	. = ..()
	var/dam_type = "bullet"
	var/damage = P.damage
	var/firer = P.firer

	// XENO REMOVED: IFF bullet check
	// if(P.runtime_iff_group && get_target_lock(P.runtime_iff_group))
	//      return

	take_damage_type(damage * 0.33, dam_type, firer)

	healthcheck()

//to handle IFF bullets
/obj/vehicle/multitile/proc/get_target_lock(access_to_check)
	if(isnull(access_to_check) || !vehicle_faction)
		return FALSE

	if(!islist(access_to_check))
		return access_to_check == vehicle_faction

	return vehicle_faction in access_to_check

/obj/vehicle/multitile/ex_act(severity, target)
	take_damage_type(severity * 0.5, "explosive")
	take_damage_type(severity * 0.1, "slash")

	healthcheck()

/// Called when a mob starts interacting with this vehicle (seat).
/obj/vehicle/multitile/proc/on_set_interaction(mob/user)
	RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, PROC_REF(crew_mousedown))
	RegisterSignal(user, COMSIG_MOB_MOUSEDRAG, PROC_REF(crew_mousedrag))
	RegisterSignal(user, COMSIG_MOB_MOUSEUP, PROC_REF(crew_mouseup))

/// Called when a mob stops interacting with this vehicle.
/obj/vehicle/multitile/proc/on_unset_interaction(mob/user)
	UnregisterSignal(user, list(COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEDRAG))

	var/obj/item/hardpoint/hardpoint = get_mob_hp(user)
	if(hardpoint)
		SEND_SIGNAL(hardpoint, COMSIG_GUN_INTERRUPT_FIRE) //abort fire when crew leaves

/// Relays crew mouse release to active hardpoint.
/obj/vehicle/multitile/proc/crew_mouseup(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	var/obj/item/hardpoint/hardpoint = get_mob_hp(source)
	if(!hardpoint)
		return

	hardpoint.stop_fire(source, object, location, control, params)

/// Relays crew mouse movement to active hardpoint.
/obj/vehicle/multitile/proc/crew_mousedrag(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	var/obj/item/hardpoint/hardpoint = get_mob_hp(source)
	if(!hardpoint)
		return

	hardpoint.change_target(source, src_object, over_object, src_location, over_location, src_control, over_control, params)

/// Checks for special control keybinds, else relays crew mouse press to active hardpoint.
/obj/vehicle/multitile/proc/crew_mousedown(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER

	var/list/modifiers = params2list(params)
	if(modifiers[SHIFT_CLICK] || modifiers[MIDDLE_CLICK] || modifiers[RIGHT_CLICK] || modifiers[BUTTON4] || modifiers[BUTTON5]) //don't step on examine, point, etc
		return

	var/seat = get_mob_seat(source)
	switch(seat)
		if(VEHICLE_DRIVER)
			if(modifiers[LEFT_CLICK] && modifiers[CTRL_CLICK])
				activate_horn()
				return
		if(VEHICLE_GUNNER)
			if(modifiers[LEFT_CLICK] && modifiers[ALT_CLICK])
				toggle_gyrostabilizer()
				return

	var/obj/item/hardpoint/hardpoint = get_mob_hp(source)
	if(!hardpoint)
		to_chat(source, span_warning("Please select an active hardpoint first."))
		return

	hardpoint.start_fire(source, object, location, control, params)

/obj/vehicle/multitile/proc/handle_player_entrance(mob/M)
	if(!M || M.client == null)
		return

	var/mob_x = M.x - src.x
	var/mob_y = M.y - src.y
	var/entrance_used = null
	for(var/entrance in entrances)
		var/entrance_coord = entrances[entrance]
		if(mob_x == entrance_coord[1] && mob_y == entrance_coord[2])
			entrance_used = entrance
			break

	var/enter_time = 0
	// door locks break when hull is destroyed
	if(door_locked && get_integrity() > 0) //check if lock on and actually works
		if(ishuman(M))
			var/mob/living/carbon/human/user = M
			if(!allowed(user) || !get_target_lock(user.faction)) //if we are human, we check access and faction
				to_chat(user, span_warning("\The [src] is locked!"))
				return
		else
			to_chat(M, span_warning("\The [src] is locked!")) //animals are not allowed inside without supervision
			return

	// Only xenos can force their way in without doors, and only when the frame is completely broken
	// XENO REMOVED: isxeno check removed
	if(!entrance_used && get_integrity() > 0)
		return

	var/enter_msg = "You start climbing into \the [src]..."

/*
	// Check if drag anything
	var/atom/dragged_atom
	if(istype(M.get_inactive_hand(), /obj/item/grab))
		var/obj/item/grab/G = M.get_inactive_hand()
		dragged_atom = G.affecting
	else if(istype(M.get_active_hand(), /obj/item/grab))
		var/obj/item/grab/G = M.get_active_hand()
		dragged_atom = G.affecting
*/

	if(!enter_time)
		enter_time = entrance_speed
		// GRAB SYSTEM DISABLED: dragged_atom was previously populated by a
		// now-commented-out grab check above; without it the var is undeclared.
		// The 2 SECONDS enter_time for dragging a pulled atom is skipped.
		// if(dragged_atom)
		//      enter_time = 2 SECONDS

	to_chat(M, span_notice(enter_msg))
	if(!cm_do_after(M, enter_time, src, INTERRUPT_NO_NEEDHAND))
		return

	if(entrance_used)
		var/entrance_coord = entrances[entrance_used]
		mob_x = M.x - src.x
		mob_y = M.y - src.y
		if(mob_x != entrance_coord[1] || mob_y != entrance_coord[2])
			to_chat(M, span_warning("\The [src] moved!"))
			return

/*
	//Dragged stuff comes with us only if properly waited 2 seconds. No cheating!
	if(dragged_atom)
		dragged_atom = null
		if(istype(M.get_inactive_hand(), /obj/item/grab))
			var/obj/item/grab/G = M.get_inactive_hand()
			dragged_atom = G.affecting
		else if(istype(M.get_active_hand(), /obj/item/grab))
			var/obj/item/grab/G = M.get_active_hand()
			dragged_atom = G.affecting


	// Transfer them to the interior
	interior.enter(M, entrance_used)

	// We try to make the dragged thing enter last so that the mob who actually entered takes precedence
	if(dragged_atom)
		var/success = interior.enter(dragged_atom, entrance_used)
		if(!success)
			to_chat(M, span_warning("You fail to fit [dragged_atom] inside \the [src] and leave [ismob(dragged_atom) ? "them" : "it"] outside."))
*/

//try to fit something into the vehicle
/obj/vehicle/multitile/proc/handle_fitting_pulled_atom(mob/living/carbon/human/user, atom/dragged_atom)
	if(!ishuman(user))
		return
	if(door_locked && get_integrity() > 0 && (!allowed(user) || !get_target_lock(user.faction)))
		to_chat(user, span_warning("\The [src] is locked!"))
		return

	var/mob_x = user.x - x
	var/mob_y = user.y - y
	var/entrance_used = null
	for(var/entrance in entrances)
		var/entrance_coord = entrances[entrance]
		if(mob_x == entrance_coord[1] && mob_y == entrance_coord[2])
			entrance_used = entrance
			break

	to_chat(user, span_notice("You start trying to fit [dragged_atom] into \the [src]..."))
	if(!cm_do_after(user, 1 SECONDS, src, INTERRUPT_NO_NEEDHAND))
		return
	if(mob_x != user.x - x || mob_y != user.y - y)
		return

/*
	var/atom/currently_dragged

	if(istype(user.get_inactive_hand(), /obj/item/grab))
		var/obj/item/grab/G = user.get_inactive_hand()
		currently_dragged = G.affecting
	else if(istype(user.get_active_hand(), /obj/item/grab))
		var/obj/item/grab/G = user.get_active_hand()
		currently_dragged = G.affecting
*/

	// GRAB SYSTEM DISABLED: currently_dragged was previously populated by a
	// now-commented-out grab check above; without it the var is undeclared.
	// The "stop fitting" early-return on a different dragged atom is skipped.
	// if(currently_dragged != dragged_atom)
	//      to_chat(user, span_warning("You stop fitting [dragged_atom] inside \the [src]!"))
	//      return

	var/success = interior.enter(dragged_atom, entrance_used)
	if(success)
		to_chat(user, span_notice("You successfully fit [dragged_atom] inside \the [src]."))
	else
		to_chat(user, span_warning("You fail to fit [dragged_atom] inside \the [src]! It's either too big or vehicle is out of space!"))
	return

//CLAMP procs, unsafe proc, checks are done before calling it
/obj/vehicle/multitile/proc/attach_clamp(obj/item/vehicle_clamp/O, mob/user)
	user.temp_drop_inv_item(O, FALSE)
	clamped = TRUE
	move_delay = VEHICLE_SPEED_STATIC
	next_move = world.time + move_delay
	qdel(O)
	update_icon()
	message_admins("[key_name(user)] attached vehicle clamp to [src]")

/obj/vehicle/multitile/proc/detach_clamp(mob/user)
	clamped = FALSE
	move_delay = initial(move_delay)

	var/obj/item/hardpoint/locomotion/Loco
	for(Loco in hardpoints)
		Loco.on_install(src) //we restore speed respective to wheels/treads if any installed

	next_move = world.time + move_delay
	var/obj/item/vehicle_clamp/O = new(get_turf(src))
	if(user)
		O.forceMove(get_turf(user))
		message_admins("[key_name(user)] detached vehicle clamp from \the [src]")
	else
		O.forceMove(get_turf(src))
		message_admins("Vehicle clamp was detached from \the [src].")
	update_icon()
