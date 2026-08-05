//Special ammo magazines for hardpoint modules. Some aren't here since you can use normal magazines on them
/obj/item/ammo_magazine/hardpoint
	flags_magazine = 0 //No refilling

/obj/item/ammo_magazine/hardpoint/attackby(obj/item/O, mob/user)
	if(O.type != type)
		to_chat(user, span_warning("You need another [initial(name)] to be able to transfer ammo."))
		return

	transfer_ammo(O, user)

/obj/item/ammo_magazine/hardpoint/transfer_ammo(obj/item/ammo_magazine/source, mob/user)
	if(current_rounds == max_rounds)
		to_chat(user, span_warning("[src] is already full."))
		return

	if(source.current_rounds == 0)
		to_chat(user, span_warning("[source] is empty, find a new one."))
		return

	if(source.caliber != caliber) //Are they the same caliber?
		to_chat(user, span_warning("Wrong ammo type."))
		return

	user.visible_message(span_warning("[user] starts refilling [src]."), span_warning("You start refilling [src]."))

	if(!cm_do_after(user, 5 SECONDS, src, INTERRUPT_ALL))
		user.visible_message(span_warning("[user] stops refilling [src]."), span_warning("You stop refilling [src]."))
		return

	var/S = min(max_rounds - current_rounds, source.current_rounds)

	source.current_rounds -= S
	current_rounds += S
	source.update_icon()
	update_icon()
	user.visible_message(span_warning("[user] finishes refilling [src]."), span_warning("You finish refilling [src]. Ammo count: [current_rounds]."))
