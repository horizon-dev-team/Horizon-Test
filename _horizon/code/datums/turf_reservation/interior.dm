/datum/turf_reservation/interior
	turf_type = /turf/open/void/vehicle

/turf/open/void
	name = "void"
	icon = 'icons/turf/space.dmi'
	icon_state = "black"
	mouse_opacity = FALSE

/turf/open/void/vehicle
	density = TRUE
	opacity = TRUE

/datum/turf_reservation/interior/Release()
	. = ..()
