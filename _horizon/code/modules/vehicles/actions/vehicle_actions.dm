// Vehicle-related action datums.
// Ported from CM13 /datum/action/human_action/* → TG /datum/action/innate/*

/// Vehicle unbuckle action — given to mobs buckled into vehicle seats.
/// Allows them to unbuckle and exit the vehicle seat.
/datum/action/innate/vehicle_unbuckle
	name = "Unbuckle From Vehicle"
	desc = "Unbuckle from your vehicle seat."
	button_icon = '_horizon/icons/actions.dmi'
	button_icon_state = "vehicle_unbuckle"

/datum/action/innate/vehicle_unbuckle/Activate()
	if(!owner)
		return
	var/obj/structure/bed/chair/comfy/vehicle/seat = owner.buckled
	if(istype(seat))
		seat.user_unbuckle_mob(owner, owner)
		return
	// Fallback: if not buckled to a vehicle seat, try generic unbuckle
	if(ismob(owner))
		var/mob/M = owner
		if(M.buckled)
			M.buckled.unbuckle_mob(M)
			Remove(M)

/// ARC toggle antenna action — given to ARC driver to raise/lower sensor antenna.
/datum/action/innate/toggle_arc_antenna
	name = "Toggle Antenna"
	desc = "Raise or lower the ARC sensor antenna."
	button_icon = '_horizon/icons/actions.dmi'
	button_icon_state = "arc_antenna"

/datum/action/innate/toggle_arc_antenna/Activate()
	if(!owner)
		return
	var/obj/vehicle/multitile/arc/arc = owner.interactee
	if(!istype(arc))
		return
	arc.toggle_antenna(owner)
