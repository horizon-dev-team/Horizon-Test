// COMPATIBILITY LAYER: CM13 vehicles → Horizon Dream
// Maps CM13 terminology to HD's atom_integrity system and other differences

// ============================================================================
// INTEGRITY SYSTEM (replaces health system)
// ============================================================================

/// Alias: health → atom_integrity
#define health atom_integrity
/// Alias: maxhealth → max_integrity
#define maxhealth max_integrity
/// Alias: max_health → max_integrity
#define max_health max_integrity

// ============================================================================
// SEAT SYSTEM — vehicles need a seats list
// ============================================================================

/// Default seats list for vehicles that don't define it
/atom/var/list/seats = list()

// ============================================================================
// MOVEMENT SYSTEM — missing vars on movable atoms
// ============================================================================

/atom/movable/var/last_move_dir = NORTH
/atom/movable/var/l_move_time = 0

// ============================================================================
// GEOMETRY MACROS — turning_angle and CORNER_BLOCK (from CM13)
// ============================================================================

/// CM13 macro: returns angle difference between dirs a and b
#define turning_angle(a, b) -(dir2angle(b) - dir2angle(a))

/// CM13 macro: returns list of turfs in a rectangle from corner
#define CORNER_BLOCK(corner, width, height) CORNER_BLOCK_OFFSET(corner, width, height, 0, 0)

/// CM13 macro: returns list of turfs in a rectangle from corner with offset
#define CORNER_BLOCK_OFFSET(corner, width, height, offset_x, offset_y) \
	block(\
		locate(corner.x + offset_x, corner.y + offset_y, corner.z),\
		locate(corner.x + offset_x + width - 1, corner.y + offset_y + height - 1, corner.z)\
	)

// ============================================================================
// BUSY ICON DEFINES — CM13 do_after compatibility
// ============================================================================

#define BUSY_ICON_GENERIC null
#define BUSY_ICON_HOSTILE null
#define BUSY_ICON_BUILD null
#define BUSY_ICON_FRIENDLY null

/// CM13 interrupt flags mapped to Horizon timed_action_flags
/// CM13 uses INTERRUPT_ALL, INTERRUPT_NO_NEEDHAND, etc.
/// Horizon uses IGNORE_USER_LOC_CHANGE, IGNORE_TARGET_LOC_CHANGE, etc.
/// CM13 INTERRUPT_ALL = interrupt on everything → Horizon: NONE (default, all interrupts)
/// CM13 INTERRUPT_NO_NEEDHAND = don't interrupt if item not held → IGNORE_HELD_ITEM
#define INTERRUPT_ALL NONE
#define INTERRUPT_NO_NEEDHAND IGNORE_HELD_ITEM

// ============================================================================
// COMSIG SIGNALS — register missing signals
// ============================================================================

#define COMSIG_MOB_MOUSEDOWN "mob_mousedown"
#define COMSIG_MOB_MOUSEDRAG "mob_mousedrag"
#define COMSIG_MOB_MOUSEUP "mob_mouseup"
#define COMSIG_GUN_INTERRUPT_FIRE "gun_interrupt_fire"
#define COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES "gun_recalculate_attachment"
#define COMSIG_ARC_ANTENNA_TOGGLED "arc_antenna_toggled"
#define COMSIG_PARENT_QDELETING "parent_qdeleting"
#define COMSIG_MOB_LOGGED_IN "mob_logged_in"
// COMSIG_ATOM_INTEGRITY_CHANGED already defined in Horizon's signals_atom_attack.dm

// ============================================================================
// BULLET/AMMO DEFINES
// ============================================================================

#define AMMO_ANTISTRUCT 1
#define AMMO_ANTIVEHICLE 2
#define AMMO_ACIDIC 4
#define AMMO_TRAIT_ENTRY "entry"
#define AMMO_TRAIT_iff "iff"

/// Bullet trait macros (CM13 → HD compatibility)
#define BULLET_TRAIT_ENTRY(trait, args...) trait = list(##args)
#define BULLET_TRAIT_ENTRY_ID(id, trait, args...) id = list(trait, ##args)

#define ANTISTRUCT_DMG_MULT_TANK 2
#define FRENZY_DAMAGE_MULTIPLIER 2

// ============================================================================
// SKILL DEFINES
// ============================================================================

#define SKILL_VEHICLE_LARGE 5
#define SKILL_VEHICLE_SMALL 0
#define SKILL_ENGINEER_NOVICE 1
#define SKILL_ENGINEER_TRAINED 2
#define SKILL_VEHICLE_CREWMAN 1
#define SKILL_POLICE 1
#define SKILL_POLICE_SKILLED 2

// ============================================================================
// JOB DEFINES
// ============================================================================

#define JOB_TANK_CREW /job/title/vehicle/tank_crew
#define JOB_UPP_CREWMAN /job/title/upp_crewman
#define JOB_PMC_CREWMAN /job/title/pmc_crewman
#define JOB_ARMY_TANK /job/title/army_tank

// ============================================================================
// EXPLOSION DEFINES (stubs)
// ============================================================================

#define EXPLOSION_FALLOFF_SHAPE_LINEAR 0

// ============================================================================
// FACTION DEFINES (stubs)
// ============================================================================

#define FACTION_MARINE "marine"

// ============================================================================
// ACCESS DEFINES (stubs)
// ============================================================================

#define ACCESS_MARINE_CREWMAN "access_marine_crewman"
#define ACCESS_MARINE_COMMAND "access_marine_command"
#define ACCESS_MARINE_BRIG "access_marine_brig"

// ============================================================================
// MINIMAP DEFINES (stubs)
// ============================================================================

#define MINIMAP_FLAG_USCM 1

// ============================================================================
// STAT DEFINES — CM13 uses CONSCIOUS, Horizon uses STABLE
// ============================================================================

#define CONSCIOUS STABLE

// ============================================================================
// HELPERS — ispowerclamp, skillcheck, etc.
// ============================================================================

/// CM13 macro: checks if object is a powerloader clamp
#define ispowerclamp(O) (istype(O, /obj/item/powerloader_clamp))

/// CM13 skillcheck stub — always passes in HD
/proc/skillcheck(mob/user, skill, level)
	return TRUE

/// CM13 give_action stub — grants a datum/action to a mob (Horizon style)
/proc/give_action(mob/M, action_type)
	if(!M || !action_type)
		return null
	var/datum/action/A = new action_type()
	A.Grant(M)
	return A

/// CM13 cell_explosion stub — uses Horizon's SSexplosions
/proc/cell_explosion(turf/epicenter, power, falloff, shape, ignored_can_explode, datum/cause_data/cause_data)
	if(!epicenter)
		return
	SSexplosions.highturf += epicenter

/// CM13 create_shrapnel stub
/proc/create_shrapnel(turf/target, count, ammo_type, datum/cause_data/cause_data)
	return

/// CM13 get_random_turf_in_range stub
/proc/get_random_turf_in_range(turf/center, range, min_range)
	if(!center)
		return null
	return get_step_rand(center)

/// CM13 explosive_antigrief_check stub
/proc/explosive_antigrief_check(obj/item/explosive/grenade/nade, mob/user)
	return FALSE

/// CM13 msg_admin_niche stub
/proc/msg_admin_niche(text)
	return

/// CM13 isxeno stub
#define isxeno(A) (istype(A, /mob/living/carbon/xenomorph))

/// CM13 BlockedPassDirs stub — Horizon uses CanPassThrough instead
/// Returns the blocked direction bits, or 0 if not blocked
/atom/proc/BlockedPassDirs(atom/movable/mover, target_dir)
	if(!CanPass(mover, get_step(src, target_dir)))
		return target_dir
	return 0

/// CM13 is_revivable stub — checks if a human can be revived
/mob/living/carbon/human/proc/is_revivable()
	return stat != DEAD && can_be_revived()

/// CM13 cause_data datum stub
/datum/cause_data
	var/cause_name = ""
	var/mob/living/victim = null
	var/datum/weakref/weak_mob
	var/datum/weakref/weak_cause
	var/ckey
	var/role
	var/faction

/datum/cause_data/New(cause_name, mob/causing_mob, obj/causing_object)
	src.cause_name = cause_name
	if(causing_mob)
		weak_mob = WEAKREF(causing_mob)
	if(causing_object)
		weak_cause = WEAKREF(causing_object)

/datum/cause_data/proc/resolve_mob()
	if(!weak_mob)
		return null
	return weak_mob.resolve()

/datum/cause_data/proc/resolve_cause()
	if(!weak_cause)
		return null
	return weak_cause.resolve()

/// CM13 create_cause_data proc — creates a cause_data datum
/proc/create_cause_data(new_cause, mob/M = null, obj/C = null)
	if(!new_cause)
		return null
	return new /datum/cause_data(new_cause, M, C)

// ============================================================================
// MOBILE PORT / CAMERA DEFINES
// ============================================================================

/// Dummy camera type for vehicles that reference /obj/structure/machinery/camera/vehicle
/obj/structure/machinery/camera/vehicle
	name = "vehicle camera"
	icon = 'icons/obj/vehicles/interiors/general.dmi'
	icon_state = "vehicle_camera"

/obj/structure/machinery/camera/vehicle/proc/toggle_cam_status(on)
	return

// ============================================================================
// VEHICLE CLAMP
// ============================================================================

/obj/item/vehicle_clamp
	name = "vehicle clamp"
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "vehicle_clamp"

// ============================================================================
// POWERLOADER CLAMP
// ============================================================================

/obj/item/powerloader_clamp
	name = "powerloader clamp"
	icon = 'icons/obj/items/weapons/projectiles.dmi'
	icon_state = "clamp"

/obj/item/powerloader_clamp/proc/grab_object(user, target, object_type, sound)
	return

// ============================================================================
// BARRICADE TYPES (placeholder)
// ============================================================================

/obj/structure/barricade/plasteel
	name = "plasteel barricade"
	max_integrity = 200

/obj/structure/barricade/metal
	name = "metal barricade"
	max_integrity = 300

// ============================================================================
// CRYO POD (placeholder)
// ============================================================================

/obj/structure/machinery/cryopod
	name = "cryopod"
	max_integrity = 250

// ============================================================================
// MOTION DETECTOR (placeholder)
// ============================================================================

/obj/item/device/motiondetector
	name = "motion detector"
	var/active = FALSE

/obj/item/device/motiondetector/proc/show_blip(show)
	return

// ============================================================================
// GRENADE (placeholder)
// ============================================================================

/obj/item/explosive/grenade
	name = "grenade"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "grenade"
	var/active = FALSE
	var/antigrief_protection = FALSE

/obj/item/explosive/grenade/proc/activate(mob/user)
	active = TRUE
	return

// ============================================================================
// GLOB — all_multi_vehicles
// ============================================================================

GLOBAL_LIST_INIT(all_multi_vehicles, list())

// ============================================================================
// VEHICLE UNBUCKLE ACTION (CM13 → HD stub)
// ============================================================================

/datum/action/human_action/vehicle_unbuckle
	name = "Unbuckle from Vehicle"
	desc = "Exit the vehicle seat."
	button_icon_state = "unbuckle"

/datum/action/human_action/vehicle_unbuckle/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!owner)
		return
	var/obj/vehicle/multitile/V = owner.interactee
	if(V && istype(V))
		V.unbuckle_mob(owner)

// ============================================================================
// TURF FLAGS (stubs for bump code)
// ============================================================================

#define TURF_HULL (1<<0)

// ============================================================================
// BULLET TRAIT IFF STUB (CM13 element, not present in Horizon)
// ============================================================================

/datum/element/bullet_trait_iff
	var/list/faction_group

/datum/element/bullet_trait_iff/Attach(datum/target, faction_group)
	. = ..()
	src.faction_group = faction_group

/datum/element/bullet_trait_iff/Detach(datum/target)
	. = ..()

// ============================================================================
// PROJECTILE STUBS — generate_bullet and apply_bullet_trait
// CM13 projectiles have these procs; Horizon does not.
// The vehicle hardpoint code calls them.
// ============================================================================

/// CM13 stub: sets up projectile from ammo datum
/obj/projectile/proc/generate_bullet(datum/ammo/A)
	return

/// CM13 stub: applies a bullet trait entry to the projectile
/obj/projectile/proc/apply_bullet_trait(list/entry)
	return

// ============================================================================
// AMMO MAGAZINE STUB — vehicle hardpoints reference /obj/item/ammo_magazine
// ============================================================================

/obj/item/ammo_magazine
	name = "magazine"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "magazine"
	var/default_ammo = null

// ============================================================================
// END OF COMPATIBILITY LAYER
// ============================================================================
