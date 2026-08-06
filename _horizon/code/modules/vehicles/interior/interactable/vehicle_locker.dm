/obj/structure/vehicle_locker
	name = "wall-mounted storage compartment"
	desc = "Small storage unit allowing vehicle crewmen to store their personal possessions or weaponry ammunition. Only vehicle crewmen can access these."
	icon = 'icons/obj/vehicles/interiors/general.dmi'
	icon_state = "locker"
	anchored = TRUE
	density = FALSE
	layer = 3.2

//      unacidable = TRUE
//      unslashable = TRUE
//      explo_proof = TRUE

	var/list/role_restriction = list(JOB_TANK_CREW, JOB_UPP_CREWMAN, JOB_PMC_CREWMAN, JOB_ARMY_TANK)

	// CM13 had `var/obj/item/storage/internal/container`. TG attaches the
	// /datum/storage component via `atom_storage` (inherited from /atom).
	// No instance var needed.

/obj/structure/vehicle_locker/Initialize()
	. = ..()
	// CM13 storage setup:
	//   container.storage_slots = null       (no slot limit)
	//   container.max_w_class = SIZE_MEDIUM  (max item size that fits; ~3 = WEIGHT_CLASS_NORMAL)
	//   container.w_class = SIZE_MASSIVE     (container's own size; not applicable to /datum/storage)
	//   container.max_storage_space = 40     (total weight cap)
	//   container.use_sound = null	   (no rustle sound)
	//   container.bypass_w_limit = list(...) (items that can exceed max_w_class)
	//
	// TG /datum/storage equivalent:
	//   max_slots (item count cap)
	//   max_specific_storage (largest w_class that fits, inclusive)
	//   max_total_storage (sum of all contents' w_class)
	//   rustle_sound (sound on insert/remove; null = use default)
	//   exception_hold (set via set_holdable; items that can exceed max_specific_storage)
	var/list/bypass_w_limit = list(
		/obj/item/gun,
		/obj/item/storage/belt,
		/obj/item/ammo_magazine/hardpoint,
	)
	create_storage(
		storage_type = /datum/storage,
		max_slots = 14, // CM13 storage_slots=null (no limit); 14 is a generous cap
		max_specific_storage = WEIGHT_CLASS_NORMAL, // CM13 max_w_class=SIZE_MEDIUM
		max_total_storage = 40, // preserved from CM13 max_storage_space
		rustle_sound = null, // CM13 use_sound=null
	)
	// bypass_w_limit items may exceed max_specific_storage.
	atom_storage.set_holdable(exception_hold_list = bypass_w_limit)
	flags_atom |= USES_HEARING

/obj/structure/vehicle_locker/verb/empty_storage()
	set name = "Empty"
	set category = "Object"
	set src in range(0)

	var/mob/living/carbon/human/H = usr
	if (!ishuman(H) || H.is_mob_restrained())
		return

	if(!role_restriction.Find(H.job))
		to_chat(H, SPAN_WARNING("You cannot access \the [name]."))
		return

	empty(get_turf(H), H)

//regular storage's empty() proc doesn't work due to checks, so imitate it
/obj/structure/vehicle_locker/proc/empty(turf/T, mob/living/carbon/human/H)
	if(!atom_storage)
		to_chat(H, SPAN_WARNING("No internal storage found."))
		return

	H.visible_message(SPAN_NOTICE("[H] starts to empty \the [src]..."), SPAN_NOTICE("You start to empty \the [src]..."))
	if(!do_after(H, 2 SECONDS, target=src))
		H.visible_message(SPAN_WARNING("[H] stops emptying \the [src]..."), SPAN_WARNING("You stop emptying \the [src]..."))
		return

	// CM13: for(var/mob/M in container.content_watchers) container.storage_close(M)
	// TG: iterate atom_storage.is_using and hide_contents() each.
	if(atom_storage.is_using)
		for(var/mob/M as anything in atom_storage.is_using)
			atom_storage.hide_contents(M)
	// CM13: for (var/obj/item/I in container.contents) container.remove_from_storage(I, T)
	// TG: atom_storage.remove_all(T) drops everything to T in one go.
	atom_storage.remove_all(T)
	H.visible_message(SPAN_NOTICE("[H] empties \the [src]."), SPAN_NOTICE("You empty \the [src]."))

	// CM13: container.empty(H, get_turf(H)) — already handled by remove_all(T) above.

/obj/structure/vehicle_locker/clicked(mob/living/carbon/human/user, list/mods)
	..()
	if(!CAN_PICKUP(user, src))
		return ..()

	if(user.get_active_hand())
		return ..()

	if(!role_restriction.Find(user.job))
		to_chat(user, SPAN_WARNING("You cannot access \the [name]."))
		return TRUE

	if(Adjacent(user))
		// CM13: container.open(user)
		// TG: atom_storage.open_storage(user) (async via INVOKE_ASYNC internally)
		atom_storage.open_storage(user)
		return TRUE

//due to how /internal coded, this doesn't work, so we used workaround above
/obj/structure/vehicle_locker/attack_hand(mob/user)
	return

/obj/structure/vehicle_locker/MouseDrop(obj/over_object)
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if(user.is_mob_incapacitated())
		return
	if(!role_restriction.Find(user.job))
		to_chat(user, SPAN_WARNING("You cannot access \the [name]."))
		return
	// CM13: if (container.handle_mousedrop(user, over_object)) ..(over_object)
	// TG: storage mousedrop is signal-driven (COMSIG_ATOM_MOUSEDROPPED_ON ->
	// /datum/storage/proc/mousedrop_receive). No explicit handle_mousedrop
	// call needed; just chain to parent so TG's normal mousedrop handling
	// (including the storage signal) runs.
	..(over_object)

/obj/structure/vehicle_locker/attackby(obj/item/W, mob/living/carbon/human/user)
	if(!Adjacent(user))
		return
	if(user.is_mob_incapacitated())
		return
	if(!istype(user))
		return
	if(!role_restriction.Find(user.job))
		to_chat(user, SPAN_WARNING("You cannot access \the [name]."))
		return
	// CM13: return container.attackby(W, user)
	// TG: atom_storage.attempt_insert(W, user) returns TRUE on success.
	return atom_storage.attempt_insert(W, user)

/obj/structure/vehicle_locker/emp_act(severity)
	. = ..()
	// CM13: container.emp_act(severity)
	// TG: /datum/storage/proc/on_emp_act is signal-driven; call it directly
	// with the source atom (src), severity, and protection=0.
	if(atom_storage)
		atom_storage.on_emp_act(src, severity, 0)

/obj/structure/vehicle_locker/hear_talk(mob/M, msg)
	// CM13: container.hear_talk(M, msg) — TG has no direct equivalent;
	// storage datums don't listen to chat. Commented out.
	// container.hear_talk(M, msg)
	..()

//Cosmetically opens/closes the locker when its storage window is accessed or closed. Only makes sound when not already open/closed.
// DISABLED: CM13 on_pocket_open / on_pocket_close callbacks have no direct TG
// /datum/storage equivalent (TG uses signal handlers and active_storage tracking,
// not first-open callbacks). The cosmetic sound/visual effects are skipped.
// /obj/structure/vehicle_locker/on_pocket_open(first_open)
//	 if(first_open)
//		 icon_state = icon_state += "_open"
//		 playsound(src.loc, 'sound/handling/hinge_squeak1.ogg', 25, TRUE, 3)
//
// /obj/structure/vehicle_locker/on_pocket_close(watchers)
//	 if(!watchers)
//		 icon_state = initial(icon_state)
//		 playsound(src.loc, "toolbox", 25, TRUE, 3)

/obj/structure/vehicle_locker/tank
	name = "storage compartment"
	desc = "Small storage unit allowing vehicle crewmen to store their personal possessions or weaponry ammunition. Only vehicle crewmen can access these."
	icon = 'icons/obj/vehicles/interiors/tank.dmi'
	icon_state = "locker"

/obj/structure/vehicle_locker/med
	name = "wall-mounted surgery kit storage"
	desc = "A small locker that securely stores a full surgical kit. ID-locked to surgeons."
	icon_state = "locker_med"
	role_restriction = list(JOB_CMO, JOB_DOCTOR)

	var/has_tray = TRUE

// DISABLED: CM13 on_pocket_open / on_pocket_close — see base type note above.
// /obj/structure/vehicle_locker/med/on_pocket_open(first_open)
//	 if(first_open)
//		 playsound(src.loc, 'sound/handling/hinge_squeak1.ogg', 25, TRUE, 3)
//
// /obj/structure/vehicle_locker/med/on_pocket_close(watchers)
//	 if(!watchers)
//		 playsound(src.loc, "toolbox", 25, TRUE, 3)

/obj/structure/vehicle_locker/med/update_icon()
	. = ..()
	if(has_tray)
		icon_state = initial(icon_state)
	else
		icon_state = "locker_open"

/obj/structure/vehicle_locker/med/attackby(obj/item/W, mob/living/carbon/human/user)
	if(!Adjacent(user))
		return
	if(user.is_mob_incapacitated())
		return
	if(!istype(user))
		return
	if(!role_restriction.Find(user.job))
		to_chat(user, SPAN_WARNING("You cannot access \the [name]."))
		return
	// CM13 surgical_tray type is not in active TG includes; istype returns
	// FALSE safely. The add_tray swap logic is therefore unreachable and
	// its body is commented out (see remove_tray/add_tray procs below).
//	if(istype(W, /obj/item/storage/surgical_tray))
//		add_tray(user, W)
//		return
	if(!has_tray)
		to_chat(user, SPAN_WARNING("\The [name] doesn't have a surgical tray installed!"))
		return
	// CM13: return container.attackby(W, user)
	// TG: atom_storage.attempt_insert(W, user)
	return atom_storage.attempt_insert(W, user)

/obj/structure/vehicle_locker/med/clicked(mob/living/carbon/human/user, list/mods)
	if(!CAN_PICKUP(user, src))
		return ..()

	if(user.get_active_hand())
		return ..()

	if(!role_restriction.Find(user.job))
		to_chat(user, SPAN_WARNING("You cannot access \the [name]."))
		return TRUE

	if(!has_tray)
		to_chat(user, SPAN_WARNING("\The [name] doesn't have a surgical tray installed!"))
		return TRUE

	if(Adjacent(user))
		// CM13: container.open(user)
		// TG: atom_storage.open_storage(user)
		atom_storage.open_storage(user)
		return TRUE

/obj/structure/vehicle_locker/med/MouseDrop(obj/over_object)
	var/mob/living/carbon/human/user = usr
	if(!istype(user))
		return
	if(user.is_mob_incapacitated())
		return
	if(!role_restriction.Find(user.job))
		to_chat(user, SPAN_WARNING("You cannot access \the [name]."))
		return
	if(!has_tray)
		to_chat(user, SPAN_WARNING("\The [name] doesn't have a surgical tray installed!"))
		return
	// CM13: if (container.handle_mousedrop(user, over_object)) ..(over_object)
	// TG: storage mousedrop is signal-driven; chain to parent for normal handling.
	..(over_object)


/obj/structure/vehicle_locker/med/verb/remove_surgical_tray()
	set name = "Remove Surgical Tray"
	set category = "Object"
	set src in oview(1)

	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/H = usr

	if(H.is_mob_incapacitated())
		return

	if(!role_restriction.Find(H.job))
		to_chat(H, SPAN_WARNING("You cannot access \the [name]."))
		return

	remove_tray(H)

// DISABLED: CM13 /obj/item/storage/surgical_tray/empty type and its
// handle_item_insertion() / remove_from_storage() CM13-storage API are not
// available in TG (TG has /obj/item/surgery_tray, a different type, with
// /datum/storage component). The tray-swap logic is commented out to avoid
// runtime/compile errors; the verb above will call this no-op stub.
/obj/structure/vehicle_locker/med/proc/remove_tray(mob/living/carbon/human/H)
	if(!has_tray)
		to_chat(H, SPAN_WARNING("The surgical tray was already removed!"))
		return

	H.visible_message(SPAN_NOTICE("[H] starts removing the surgical tray from \the [src]."), SPAN_NOTICE("You start removing the surgical tray from \the [src]."))
	if(!do_after(H, 2 SECONDS, target=src, timed_action_flags=INTERRUPT_NO_NEEDHAND))
		H.visible_message(SPAN_NOTICE("[H] stops removing the surgical tray from \the [src]."), SPAN_WARNING("You stop removing the surgical tray from \the [src]."))
		return

	// SURGICAL TRAY SWAP DISABLED: /obj/item/storage/surgical_tray/empty is
	// not in active TG includes. Original logic created a tray instance,
	// moved all locker contents into it, then put the tray in H's hands.
	// To re-enable, port CM13 surgical_tray to TG /datum/storage API or
	// use TG's /obj/item/surgery_tray type.
	// var/obj/item/storage/surgical_tray/empty/tray = new(loc)
	// var/turf/T = get_turf(src)
	// for(var/obj/item/O in atom_storage.real_location.contents)
	//	 atom_storage.attempt_remove(O, T)
	//	 tray.atom_storage.attempt_insert(O, H)
	// has_tray = FALSE
	// update_icon()
	// H.put_in_hands(tray)
	// atom_storage.hide_contents(H)
	// H.visible_message(SPAN_NOTICE("[H] removes the surgical tray from \the [src]."), SPAN_NOTICE("You remove the surgical tray from \the [src]."))
	return

// DISABLED: see remove_tray note above.
/*
/obj/structure/vehicle_locker/med/proc/add_tray(mob/living/carbon/human/H, obj/item/storage/surgical_tray/tray)
	if(has_tray)
		to_chat(H, SPAN_WARNING("\The [src] already has a surgical tray installed!"))
		return

	H.visible_message(SPAN_NOTICE("[H] starts installing \the [tray] into \the [src]."), SPAN_NOTICE("You start installing \the [tray] into \the [src]."))
	if(!do_after(H, 2 SECONDS, target=src, timed_action_flags=INTERRUPT_NO_NEEDHAND))
		H.visible_message(SPAN_NOTICE("[H] stops installing \the [tray] into \the [src]."), SPAN_WARNING("You stop installing \the [tray] into \the [src]."))
		return

	// SURGICAL TRAY SWAP DISABLED: tray.handle_item_insertion() and
	// tray.remove_from_storage() are CM13 storage API not present on TG
	// /obj/item/storage. Original logic moved all tray contents into the
	// locker, then deleted the tray.
	// var/turf/T = get_turf(src)
	// for(var/obj/item/O in tray.atom_storage.real_location.contents)
	//	 tray.atom_storage.attempt_remove(O, T)
	//	 atom_storage.attempt_insert(O, H)
	// H.drop_held_item(tray)
	// qdel(tray)
	// has_tray = TRUE
	// update_icon()
	// H.visible_message(SPAN_NOTICE("[H] installs \the [tray] into \the [src]."), SPAN_NOTICE("You install \the [tray] into \the [src]."))
	return
*/

/obj/structure/vehicle_locker/pmc
	icon = 'icons/obj/vehicles/interiors/general_wy.dmi'
	role_restriction = list(JOB_PMC_LEAD_INVEST, JOB_PMC_LEADER, JOB_PMC_SYNTH, JOB_WY_COMMANDO_LEADER, JOB_PMC_CREWMAN)
