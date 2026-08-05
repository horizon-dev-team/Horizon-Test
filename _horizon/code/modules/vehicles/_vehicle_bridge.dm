// Bridge layer: maps CM13 vehicle concepts to TG architecture.
// This file contains ONLY things that genuinely need bridging:
// - Vars that TG doesn't have on the right types
// - Helper procs that map CM13 API calls to TG equivalents
// - Macros for CM13 text styles not present in TG
// All stubs are clearly marked with TODO comments.

// ============================================================================
// MOB VARS — CM13 interaction system
// ============================================================================

/// CM13: tracks what obj/vehicle a mob is currently interacting with (e.g. vehicle seat).
/// TG doesn't have this concept; multitile vehicles use it for seat management.
/mob/var/atom/interactee = null

/// CM13: whether a mob is currently busy with a do_after action.
/// TG tracks this via the do_afters list, but CM13 code checks action_busy directly.
/mob/var/action_busy = FALSE

/// CM13: intent system. TG uses combat_mode (boolean) instead.
/// This is kept for CM13 code compatibility — combat_mode = (a_intent == INTENT_HARM)
/mob/var/a_intent = INTENT_HELP

/// CM13: faction group for IFF checks. TG uses faction (string).
/mob/var/faction_group = null

// ============================================================================
// ATOM/MOVABLE VARS — movement tracking
// ============================================================================

/// CM13: last direction this atom moved in.
/atom/movable/var/last_move_dir = NORTH

/// CM13: world.time of last movement.
/atom/movable/var/l_move_time = 0

// ============================================================================
// SPAN MACROS — CM13 text styles not in TG
// ============================================================================

// #define SPAN_HELPFUL(str) span_nicegreen(str)
// #define SPAN_XENOWARNING(str) span_warning(str) // XENO REMOVED — mapped to warning
// #define SPAN_XENOBOLDNOTICE(str) span_boldnotice(str) // XENO REMOVED — mapped to boldnotice
// #define SPAN_BOLD(str) span_bold(str)
// #define SPAN_INFO(str) span_info(str)

// ============================================================================
// GLOBAL HELPERS
// ============================================================================

/// CM13: broadcast to world. TG uses to_chat(world).
#define to_world(msg) to_chat(world, msg)

/// CM13: check if item is a welder. TG uses tool_behaviour == TOOL_WELDER.
/proc/iswelder(obj/item/I)
	return I?.tool_behaviour == TOOL_WELDER

/// CM13: check if item is a crowbar.
/proc/iscrowbar(obj/item/I)
	return I?.tool_behaviour == TOOL_CROWBAR

/// CM13: check if item is a wrench.
/proc/iswrench(obj/item/I)
	return I?.tool_behaviour == TOOL_WRENCH

/// CM13: check if item is a screwdriver.
/proc/isscrewdriver(obj/item/I)
	return I?.tool_behaviour == TOOL_SCREWDRIVER

/// CM13: check if a mob is incapacitated. TG uses TRAIT_INCAPACITATED.
/proc/is_mob_incapacitated(mob/M, check_stat = FALSE)
	if(!istype(M))
		return FALSE
	if(HAS_TRAIT(M, TRAIT_INCAPACITATED))
		return TRUE
	if(check_stat && M.stat != CONSCIOUS)
		return TRUE
	return FALSE

// ============================================================================
// DO_AFTER — CM13 signature wrapper
// CM13: do_after(user, delay, timed_action_flags, busy_icon, ...)
// TG:    do_after(user, delay, target, timed_action_flags, ...)
// This wrapper accepts CM13-style args and forwards to TG do_after.
// ============================================================================

/// CM13 do_after wrapper. Accepts (user, delay, flags, busy_icon) and forwards to TG.
/// INTERRUPT_ALL = NONE, INTERRUPT_NO_NEEDHAND = IGNORE_HELD_ITEM
/proc/cm_do_after(mob/user, delay, atom/target, timed_action_flags = NONE, busy_icon = null, numticks, target_flags)
	if(!user)
		return FALSE
	if(isnull(target))
		target = user
	return do_after(user, delay, target, timed_action_flags = timed_action_flags)

// ============================================================================
// SKILL SYSTEM — TG doesn't have CM13 skills
// ============================================================================

#define SKILL_VEHICLE_LARGE 5
#define SKILL_VEHICLE_SMALL 0
//#define SKILL_ENGINEER_NOVICE 1
//#define SKILL_ENGINEER_TRAINED 2
//#define SKILL_ENGINEER 3
//#define SKILL_VEHICLE 4
//#define SKILL_VEHICLE_CREWMAN 1
#define SKILL_POLICE 5
#define SKILL_POLICE_SKILLED 2

/// CM13 skillcheck — always passes in TG (no skill system).
/proc/skillcheck(mob/user, skill, level)
	return TRUE

/// CM13 skill duration multiplier — returns 1 (no skill system).
/mob/proc/get_skill_duration_multiplier(skill)
	return 1

// ============================================================================
// ITEM MANIPULATION — CM13 API → TG equivalents
// ============================================================================

/// CM13: drop item to loc. TG: transferItemToLoc.
/mob/proc/temp_drop_inv_item(obj/item/I, force)
	if(!I)
		return FALSE
	return transferItemToLoc(I, get_turf(src), force = force)

/// CM13: drop item to specific loc. TG: transferItemToLoc.
/mob/proc/drop_inv_item_to_loc(obj/item/I, atom/dest)
	if(!I)
		return FALSE
	return transferItemToLoc(I, dest)

/// CM13: drop held item. TG: dropItemToGround.
/mob/proc/drop_held_item()
	var/obj/item/I = get_active_held_item()
	if(I)
		dropItemToGround(I)

// Note: get_active_hand() and get_inactive_hand() already exist in TG
// at code/modules/surgery/bodyparts/helpers.dm — no need to redefine.

// ============================================================================
// GRAMMAR HELPERS — CM13 pluralization
// Note: p_are() and p_s() already exist in TG at code/__HELPERS/pronouns.dm
// ============================================================================

// ============================================================================
// CAUSE DATA — CM13 cause tracking (simplified for TG)
// ============================================================================

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

/proc/create_cause_data(new_cause, mob/M = null, obj/C = null)
	if(!new_cause)
		return null
	return new /datum/cause_data(new_cause, M, C)

// ============================================================================
// EXPLOSION HELPERS — map CM13 to TG
// ============================================================================

#define EXPLOSION_FALLOFF_SHAPE_LINEAR 0

/// CM13 cell_explosion — maps to TG SSexplosions.
/proc/cell_explosion(turf/epicenter, power, falloff, shape, ignored_can_explode, datum/cause_data/cause_data)
	if(!epicenter)
		return
	var/devastation_range = round(power / 100)
	var/heavy_impact_range = round(power / 50)
	var/light_impact_range = round(power / 25)
	explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range)

/// CM13 create_shrapnel — TODO: implement with TG projectile system.
/proc/create_shrapnel(turf/target, count, ammo_type, datum/cause_data/cause_data)
	return

/// CM13 get_random_turf_in_range
/proc/get_random_turf_in_range(turf/center, radius, min_radius = 0)
	if(!center)
		return null
	var/list/turfs = list()
	for(var/turf/T in orange(radius, center))
		if(get_dist(center, T) >= min_radius)
			turfs += T
	if(!length(turfs))
		return null
	return pick(turfs)

/// CM13 explosive_antigrief_check — no antigrief in TG.
/proc/explosive_antigrief_check(obj/item/explosive/grenade/nade, mob/user)
	return FALSE

// ============================================================================
// ADMIN HELPERS — map CM13 to TG
// ============================================================================

/// CM13 msg_admin_niche — maps to TG admin logging.
/proc/msg_admin_niche(text)
	log_admin(text)

/// CM13 msg_admin_ff — friendly fire notification.
/proc/msg_admin_ff(text, alert_admins, z)
	log_admin(text)

/// CM13 log_attack — already exists in TG at code/__HELPERS/logging/attack.dm
// Removed duplicate definition.

/// CM13 ADMIN_JMP — maps to TG admin teleport.
#define ADMIN_JMP(atom) "([ADMIN_JMPSRC(atom)])"

/// CM13 ADMIN_PM — maps to TG admin PM.
#define ADMIN_PM(mob) ""
/*
/// CM13 WRAP_STAFF_LOG — simplified for TG.
#define WRAP_STAFF_LOG(user, text) "[key_name(user)] [text]"
*/
// ============================================================================
// IFF / FACTION — CM13 target lock system
// ============================================================================

/// CM13 get_target_lock — checks if attacker faction matches vehicle faction.
/// TODO: integrate with TG faction system properly.
/proc/get_target_lock(faction_group)
	return FALSE

// ============================================================================
// PASSABILITY — CM13 BlockedPassDirs
// ============================================================================

/// CM13 BlockedPassDirs — returns blocked direction bits.
/// TG uses CanPass/CanPassThrough instead.
/atom/proc/BlockedPassDirs(atom/movable/mover, target_dir)
	if(!CanPass(mover, get_step(src, target_dir)))
		return target_dir
	return 0

// ============================================================================
// BULLET VISUALS — CM13 bullet_ping
// ============================================================================

/// CM13 bullet_ping — visual effect for bullets hitting vehicles.
/// TODO: implement with TG visual effects if needed.
/proc/bullet_ping(obj/projectile/P, pixel_x_offset, pixel_y_offset)
	return

// ============================================================================
// ISXENO — XENO REMOVED
// ============================================================================

// XENO REMOVED: isxeno always returns FALSE
#define isxeno(A) FALSE

// ============================================================================
// GLOB — all_multi_vehicles
// ============================================================================

GLOBAL_LIST_INIT(all_multi_vehicles, list())

/// Helper to check if an atom is a multitile vehicle
/proc/isVehicleMultitile(atom/A)
	return istype(A, /obj/vehicle/multitile)

// ============================================================================
// VEHICLE UNBUCKLE ACTION — adapted to TG action system
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
// GIVE_ACTION — CM13 → TG action grant
// ============================================================================

/// CM13 give_action — creates and grants a datum/action to a mob.
/proc/give_action(mob/M, action_type)
	if(!M || !action_type)
		return null
	var/datum/action/A = new action_type()
	A.Grant(M)
	return A

// ============================================================================
// MINIMAP — TG does not have SSminimaps
// ============================================================================

// SSminimaps does not exist in TG. All minimap calls are no-ops.
// TODO: implement minimap support if needed, or remove references.

// ============================================================================
// AMMO / BULLET DEFINES — CM13 ammo system (simplified)
// ============================================================================

#define AMMO_ANTISTRUCT 1
#define AMMO_ANTIVEHICLE 2
#define AMMO_ACIDIC 4
#define AMMO_HITS_TARGET_TURF (1<<0)
#define AMMO_EXPLOSIVE (1<<1)

#define ANTISTRUCT_DMG_MULT_TANK 2
#define FRENZY_DAMAGE_MULTIPLIER 2

/// Bullet trait macros (CM13 → TG compatibility)
#define BULLET_TRAIT_ENTRY(trait, args...) trait = list(##args)
#define BULLET_TRAIT_ENTRY_ID(id, trait, args...) id = list(trait, ##args)

/// CM13 projectile proc: sets up projectile from ammo datum.
/// TODO: adapt to TG projectile system.
/obj/projectile/proc/generate_bullet(datum/ammo/A)
	return

/// CM13 projectile proc: applies a bullet trait entry.
/// TODO: adapt to TG projectile system.
/obj/projectile/proc/apply_bullet_trait(list/entry)
	return

// ============================================================================
// COMSIG SIGNALS — not already defined in TG
// ============================================================================

#define COMSIG_MOB_MOUSEDOWN "mob_mousedown"
#define COMSIG_MOB_MOUSEDRAG "mob_mousedrag"
#define COMSIG_MOB_MOUSEUP "mob_mouseup"
#define COMSIG_GUN_INTERRUPT_FIRE "gun_interrupt_fire"
#define COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES "gun_recalculate_attachment"
#define COMSIG_ARC_ANTENNA_TOGGLED "arc_antenna_toggled"

// ============================================================================
// JOB DEFINES — CM13 jobs (placeholder)
// ============================================================================

#define JOB_TANK_CREW /datum/job/vehicle/tank_crew
#define JOB_UPP_CREWMAN /datum/job/upp_crewman
#define JOB_PMC_CREWMAN /datum/job/pmc_crewman
#define JOB_ARMY_TANK /datum/job/army_tank

// ============================================================================
// STAT DEFINES — CM13 CONSCIOUS = TG STABLE
// ============================================================================

// CONSCIOUS is already defined as STABLE in code/__DEFINES/stat.dm
// This is kept for reference:
// #define CONSCIOUS STABLE

// ============================================================================
// BUSY ICON DEFINES — CM13 do_after icons (not used in TG)
// ============================================================================

#define BUSY_ICON_GENERIC null
#define BUSY_ICON_HOSTILE null
#define BUSY_ICON_BUILD null
#define BUSY_ICON_FRIENDLY null

// ============================================================================
// INTERRUPT FLAGS — map CM13 to TG timed_action_flags
// ============================================================================

#define INTERRUPT_ALL NONE
#define INTERRUPT_NO_NEEDHAND IGNORE_HELD_ITEM
#define INTERRUPT_DIFF_LOC IGNORE_TARGET_LOC_CHANGE

// ============================================================================
// GRAB — CM13 grab item type (TG uses mob.pulling instead)
// This minimal type allows CM13 vehicle code to compile.
// ============================================================================

/obj/item/grab
	name = "grab"
	icon = 'icons/obj/items/weapons/projectiles.dmi'
	icon_state = "grab"
	item_flags = ABSTRACT | DROPDEL | HAND_ITEM
	/// The atom being grabbed (CM13: grabbed_thing, TG: mob.pulling)
	var/atom/grabbed_thing
	/// CM13 alias for grabbed_thing
	var/atom/affecting

/obj/item/grab/Initialize(mapload, ...)
	. = ..()
	if(!grabbed_thing && ismob(loc))
		grabbed_thing = loc.pulling
		affecting = grabbed_thing

// ============================================================================
// ISPOWERCLAMP — CM13 powerloader clamp check
// ============================================================================

/proc/ispowerclamp(obj/item/I)
	return istype(I, /obj/item/powerloader_clamp)

// ============================================================================
// CAMERA / VEHICLE CLAMP / POWERLOADER — placeholder types
// TODO: port these properly or replace with TG equivalents.
// ============================================================================

/obj/structure/machinery/camera/vehicle
	name = "vehicle camera"
	icon = 'icons/obj/vehicles/interiors/general.dmi'
	icon_state = "vehicle_camera"

/obj/structure/machinery/camera/vehicle/proc/toggle_cam_status(on)
	return

/obj/item/vehicle_clamp
	name = "vehicle clamp"
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "vehicle_clamp"

/obj/item/powerloader_clamp
	name = "powerloader clamp"
	icon = 'icons/obj/items/weapons/projectiles.dmi'
	icon_state = "clamp"
	var/linked_powerloader
	var/obj/item/loaded

/obj/item/powerloader_clamp/proc/grab_object(user, target, object_type, sound)
	return

/obj/item/powerloader_clamp/update_icon()
	return

// ============================================================================
// AMMO MAGAZINE — CM13 hardpoint ammo
// TODO: port properly or adapt to TG ammo system.
// ============================================================================

/obj/item/ammo_magazine
	name = "magazine"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "magazine"
	var/default_ammo = null
	var/current_rounds = 0
	var/max_rounds = 0
	var/caliber = null
	var/flags_magazine = 0

/obj/item/ammo_magazine/hardpoint
	name = "hardpoint magazine"

// ============================================================================
// PROJECTILE — CM13 ammo datum (simplified)
// TODO: adapt to TG projectile system.
// ============================================================================

/datum/ammo
	var/name = "ammo"
	var/flags_ammo_behavior = 0
	var/penetration = 0
	var/max_range = 30
	var/shell_speed = 3

/datum/ammo/bullet/shrapnel
	name = "shrapnel"

// ============================================================================
// BARRICADE TYPES — referenced by bump code
// ============================================================================

// TG already has /obj/structure/barricade — these are CM13 subtypes.
// TODO: port or replace with TG barricade equivalents.

// ============================================================================
// MOTION DETECTOR — referenced by interaction code
// TODO: port or remove references.
// ============================================================================

/obj/item/device/motiondetector
	name = "motion detector"
	var/active = FALSE

/obj/item/device/motiondetector/proc/show_blip(show)
	return

// ============================================================================
// GRENADE — referenced by interaction code
// ============================================================================

// TG already has /obj/item/grenade. CM13 uses /obj/item/explosive/grenade.
// TODO: adapt references to TG grenade type.

// ============================================================================
// BULLET TRAIT IFF — CM13 element
// ============================================================================

/datum/element/bullet_trait_iff
	var/list/faction_group

/datum/element/bullet_trait_iff/Attach(datum/target, faction_group)
	. = ..()
	src.faction_group = faction_group

/datum/element/bullet_trait_iff/Detach(datum/target)
	. = ..()

// ============================================================================
// EXPLO_PROOF — CM13 explosion immunity flag
// ============================================================================

/// CM13 explo_proof — if TRUE, immune to explosions.
/// TG uses resistance_flags & INDESTRUCTIBLE.
/obj/item/var/explo_proof = FALSE

// ============================================================================
// MISSING HELPERS — CM13 procs not in TG
// ============================================================================

/// CM13 Get_Angle — TG uses lowercase get_angle
/proc/Get_Angle(atom/A, atom/B)
	return get_angle(A, B)

/// CM13 get_turf_on_clickcatcher — returns turf from click params
/proc/get_turf_on_clickcatcher(atom/object, mob/user, params)
	var/turf/T = get_turf(object)
	if(!T)
		T = get_turf(user)
	return T

/// CM13 simulate_scatter — adjusts target based on scatter angle
/proc/simulate_scatter(obj/projectile/P, atom/target, turf/curloc, turf/targloc, mob/user)
	return target

/// CM13 /datum/component/automatedfire/autofire — stub for TG compatibility
/// TG uses /datum/component/automatic_fire instead.
/datum/component/automatedfire/autofire

// ============================================================================
// PROJECTILE BRIDGE — CM13 ammo datum on TG projectiles
// ============================================================================

/// CM13: projectiles carry an ammo datum with behavior flags, range, speed.
/// TG projectiles have these directly as vars. This bridge var lets CM13
/// hardpoint firing code access them through the ammo datum interface.
/obj/projectile/var/datum/ammo/ammo
/obj/projectile/var/projectile_override_flags = 0

// ============================================================================
// SHOW_BROWSER — CM13 browser helper → TG /datum/browser
// ============================================================================

/// CM13 show_browser — opens a browser window with content.
/proc/show_browser(mob/user, content, title, window_id, width = 0, height = 0)
	var/datum/browser/popup = new(user, window_id, title, width, height)
	popup.set_content(content)
	popup.open()

// ============================================================================
// TURF RESERVATION — CM13 interior system
// ============================================================================

/// CM13: /datum/turf_reservation/interior — used by vehicle interiors.
/// TG has /datum/turf_reservation but not the interior subtype.
/datum/turf_reservation/interior
	name = "interior reservation"

// ============================================================================
// MISC HELPERS
// ============================================================================

/// CM13: isVehicleMultitile — checks if atom is a multitile vehicle.
/atom/proc/isVehicleMultitile()
	return istype(src, /obj/vehicle/multitile)
/*
/// CM13: WRAP_STAFF_LOG — admin logging wrapper.
/proc/WRAP_STAFF_LOG(mob/user, text)
	log_admin("[key_name(user)] [text]")
*/
