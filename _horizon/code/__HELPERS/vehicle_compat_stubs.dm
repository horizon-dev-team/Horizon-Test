// Horizon vehicle compatibility stubs.
// These procs/types wrap CM13-specific APIs to TG equivalents so that
// ported CM13 vehicle code compiles and runs under TG (BYOND 516.1685).
//
// All stubs here are intentionally minimal — they exist to bridge the
// gap between CM13 API and TG API. Stubs that return FALSE/no-op
// may need to be replaced with real TG implementations if full
// functionality is needed.

// ============================================================================
// SKILL SYSTEM STUBS — TG does not have skillcheck()
// ============================================================================

/// CM13 skill check — TG has no skill system, so always returns TRUE.
/proc/skillcheck(mob/user, skill, level)
	return TRUE

/// CM13 skill duration multiplier — always 1.0 in TG (no skills).
/mob/proc/get_skill_duration_multiplier(skill)
	return 1.0

// ============================================================================
// CM13 DO_AFTER SHIM — bridges cm_do_after() to TG do_after()
// ============================================================================

/// CM13 cm_do_after(user, delay, target, interrupt_flags, busy_icon) → TG do_after().
/// `interrupt_flags` and `busy_icon` are ignored — TG uses `timed_action_flags`.
/proc/cm_do_after(atom/movable/user, delay, atom/target, interrupt_flags = NONE, busy_icon = null)
	return do_after(user, delay, target = target, timed_action_flags = interrupt_flags)

// ============================================================================
// MOB HELPER STUBS — CM13 has these; TG uses different API
// ============================================================================

/// CM13 is_mob_incapacitated → TG trait check
/proc/is_mob_incapacitated(mob/M, ignore_flags = FALSE)
	if(!istype(M))
		return FALSE
	return HAS_TRAIT(M, TRAIT_INCAPACITATED)

/// CM13 is_mob_restrained → TG trait check
/mob/living/proc/is_mob_restrained()
	return HAS_TRAIT(src, TRAIT_RESTRAINED)

/// CM13 is_revivable → TG has its own defib/revive system; default FALSE
/mob/living/carbon/human/proc/is_revivable()
	return FALSE

/// CM13 isxeno — TG has no xenomorphs
/proc/isxeno(mob/M)
	return FALSE

/// CM13 issynth — TG has no synthetic human subtype
/proc/issynth(mob/M)
	return FALSE

/// CM13 isVehicleMultitile
/proc/isVehicleMultitile(atom/A)
	return istype(A, /obj/vehicle/multitile)

/// CM13 isVehicle — checks if the arg is any /obj/vehicle. TG has its own
/// /obj/vehicle type (single-tile, different architecture); istype check
/// works for both TG-native and CM13-ported /obj/vehicle/multitile.
/proc/isVehicle(atom/A)
	return istype(A, /obj/vehicle)

/// CM13 is_ground_level — TG has no z-level hierarchy like CM13
/proc/is_ground_level(z)
	return TRUE

// ============================================================================
// TOOL HELPERS — CM13 has iscrowbar/iswelder/etc; TG uses tool_behaviour
// ============================================================================

/proc/iscrowbar(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_CROWBAR

/proc/iswelder(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_WELDER

/proc/iswrench(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_WRENCH

/proc/isscrewdriver(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_SCREWDRIVER

/proc/iscablecoil(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_WIRECUTTER

/// CM13 ispowerclamp — TG has no powerloader_clamp
/proc/ispowerclamp(obj/item/O)
	return FALSE

// ============================================================================
// MOB VAR SHIMS — CM13 mob vars that don't exist in TG
// ============================================================================

/// CM13 mob.interactee — atom the mob is currently interacting with (e.g. vehicle)
/mob/var/atom/interactee = null

/// CM13 human.allow_gun_usage
/mob/living/carbon/human/var/allow_gun_usage = TRUE

/// CM13 mob.a_intent — TG uses combat_mode (boolean) instead of intent strings.
/// Stub defaults to INTENT_HELP so existing `if(user.a_intent != INTENT_HARM)`
/// checks evaluate TRUE (non-hostile), preserving vehicle entry behavior.
/// Replace with `combat_mode` translation if harm-intent vehicle attacks
/// need to be re-enabled.
/mob/var/a_intent = INTENT_HELP

// ============================================================================
// MOB PROC SHIMS — CM13 mob procs that don't exist in TG
// ============================================================================

///// CM13 get_active_hand → TG get_active_held_item
///mob/proc/get_active_hand()
//	return get_active_held_item()
//
///// CM13 get_inactive_hand → TG get_inactive_held_item
///mob/proc/get_inactive_hand()
//	return get_inactive_held_item()
//
///// CM13 drop_held_item → TG dropItemToGround
///mob/proc/drop_held_item(obj/item/I)
//	if(!I)
//		return FALSE
//	return dropItemToGround(I)

/// CM13 temp_drop_inv_item → TG transferItemToLoc
/mob/proc/temp_drop_inv_item(obj/item/I, force = FALSE)
	if(!I)
		return FALSE
	return transferItemToLoc(I, drop_location())

/// CM13 hear_talk — TG uses different hearing signal system
/atom/movable/proc/hear_talk(mob/M, list/message_pieces)
	return

/// CM13 handle_click — TG has no equivalent (uses COMSIG_MOB_CLICKED)
/mob/living/proc/handle_click(mob/living/user, atom/A, list/mods)
	return

/// CM13 atom.get_projectile_hit_boolean(obj/projectile/P) — returns TRUE if the
/// projectile should hit this atom, FALSE to let it pass through. TG uses
/// `pass_flags_self` / `CanPass` for projectile blocking instead. Stub returns
/// TRUE (default block) so ported CM13 overrides that return FALSE compile.
/atom/proc/get_projectile_hit_boolean(obj/projectile/P)
	return TRUE

/// CM13 mob.unset_interaction — clears the mob's interactee (e.g. vehicle).
/// In CM13 this also called interactee.on_unset_interaction(src); TG has no
/// such chain, so the vehicle-side on_unset_interaction is invoked separately
/// (via signals or explicit calls). Stub here just clears interactee.
/mob/proc/unset_interaction()
	interactee = null

// ============================================================================
// PROJECTILE SHIMS — CM13 projectile API
// ============================================================================

/// CM13 projectile.get_effective_accuracy — TG uses different accuracy system
/obj/projectile/proc/get_effective_accuracy()
	return 0

/// CM13 simulate_scatter — TG has different scatter system
/proc/simulate_scatter(obj/projectile/P, atom/target, turf/origin, turf/target_turf, mob/user)
	return target

// ============================================================================
// EXPLOSION SHIMS — CM13 cell_explosion/create_shrapnel → TG explosion()
// ============================================================================

/// CM13 cell_explosion — wraps to TG explosion()
/proc/cell_explosion(turf/epicenter, strength, falloff = 1, shape = EXPLOSION_FALLOFF_SHAPE_LINEAR, direction = null, datum/cause_data/cause_data)
	explosion(epicenter, strength, strength * 0.5, strength * 0.25)

/// CM13 create_shrapnel — TG has no direct equivalent; no-op for now
/proc/create_shrapnel(turf/T, count, spread_angle_min, spread_angle_max, datum/ammo/A, datum/cause_data/C)
	return

/// CM13 explosive_antigrief_check — TG has no antigrief system
/proc/explosive_antigrief_check(obj/O, mob/user)
	return FALSE

/// CM13 get_random_turf_in_range
/proc/get_random_turf_in_range(turf/centre, range, min_range = 0)
	if(!centre)
		return null
	var/list/turfs = list()
	for(var/turf/T in RANGE_TURFS(range, centre))
		if(min_range && get_dist(centre, T) < min_range)
			continue
		turfs += T
	if(!length(turfs))
		return null
	return pick(turfs)

// ============================================================================
// ADMIN HELPERS — CM13 has msg_admin_ff, msg_admin_niche
// ============================================================================

/proc/msg_admin_ff(message)
	message_admins(message)

/proc/msg_admin_niche(message)
	message_admins(message)

// ============================================================================
// WELDING TOOL SHIM — CM13 has weldingtool.remove_fuel()
// ============================================================================

/obj/item/weldingtool/proc/remove_fuel(amount = 1, mob/user)
	if(get_fuel() >= amount)
		use(amount)
		return TRUE
	return FALSE

// ============================================================================
// ACTION GRANT SHIM — CM13 has global give_action(mob, /datum/action/path);
// TG uses `new /datum/action/...().Grant(mob)` instead.
// ============================================================================

/// CM13 give_action — instantiates the given action type and grants it to the mob.
/// Returns the created action datum (or null on failure).
/proc/give_action(mob/grant_to, action_type)
	if(!grant_to || !ispath(action_type, /datum/action))
		return null
	var/datum/action/A = new action_type(grant_to)
	A.Grant(grant_to)
	return A

// ============================================================================
// MOB VAR STUBS — CM13 mob vars that don't exist in TG
// ============================================================================

/// CM13 mob.action_busy — TRUE when a do_after is in progress.
/// TG uses DOING_INTERACTION(user) macro instead. Stub var for compile compat.
/mob/var/action_busy = FALSE

// ============================================================================
// CLICK CATCHER SHIM — CM13 get_turf_on_clickcatcher
// ============================================================================

/// CM13 get_turf_on_clickcatcher — processes a clicked target; if the target
/// is the screen-edge click catcher, returns the turf at the click position.
/// Minimal stub: returns target if it's not a screen object, else returns
/// the user's turf (best-effort fallback for TG's different click_catcher API).
/proc/get_turf_on_clickcatcher(atom/target, mob/user, params)
	if(istype(target, /atom/movable/screen))
		return get_turf(user)
	return target

// ============================================================================
// IMAGE FLICK_OVERLAY SHIM — CM13 has /image/proc/flick_overlay(atom, duration)
// TG has /atom/proc/flick_overlay(image, list/show_to, duration, layer) instead
// (different signature, different semantics). Port the CM13 /image proc here.
// ============================================================================

/// CM13 /image/proc/flick_overlay — temporarily adds the image as an overlay
/// on the target atom, then removes it after duration (in deciseconds).
/image/proc/flick_overlay(atom/A, duration)
	if(!A)
		return
	A.add_overlay(src)
	addtimer(CALLBACK(src, PROC_REF(flick_remove_overlay), A), duration)

/// CM13 /image/proc/flick_remove_overlay — companion to flick_overlay.
/image/proc/flick_remove_overlay(atom/A)
	if(A)
		A.cut_overlay(src)

// ============================================================================
// BED/CHAIR API SHIMS — CM13 /obj/structure/bed API → TG /atom/movable API.
// TG separates /obj/structure/bed (beds) from /obj/structure/chair (chairs).
// CM13 used a unified /obj/structure/bed/chair/* path for chairs. These stubs
// let ported CM13 seat code compile and run on TG /obj/structure/bed by
// aliasing the CM13 single-mob buckled_mob var and the CM13 afterbuckle /
// do_buckle / manual_unbuckle / unbuckle / handle_rotation procs to their
// TG equivalents (buckled_mobs list, user_buckle_mob, user_unbuckle_mob,
// unbuckle_all_mobs, post_buckle_mob / post_unbuckle_mob).
// ============================================================================

/// CM13 bed.buckled_mob — single mob alias for TG buckled_mobs[1].
/// Kept in sync via the post_buckle_mob / post_unbuckle_mob overrides below.
/obj/structure/bed/var/mob/living/buckled_mob = null

/// CM13 bed.can_rotate — TG only has this on /obj/structure/chair.
/obj/structure/bed/var/can_rotate = FALSE

/// CM13 bed.buildstackamount — TG uses build_stack_amount (different name).
/obj/structure/bed/var/buildstackamount = 0

/// CM13 bed.picked_up_item — referenced (but unused) in seats.dm.
/obj/structure/bed/var/picked_up_item = null

/// CM13 bed.unslashable — TG has no equivalent (uses resistance_flags).
/obj/structure/bed/var/unslashable = FALSE

/// CM13 bed.explo_proof — TG has no equivalent (uses resistance_flags).
/obj/structure/bed/var/explo_proof = FALSE

/// CM13 bed.handle_rotation — TG chair has this; stub no-op on bed.
/obj/structure/bed/proc/handle_rotation()
	return

/// CM13 bed.afterbuckle(mob/M) — called after a buckle/unbuckle event.
/// Subclasses (e.g. vehicle seats) override to update icon_state, vehicle
/// linkage, view, etc. This base stub is a no-op; the post_buckle_mob /
/// post_unbuckle_mob overrides below keep buckled_mob in sync and forward
/// to afterbuckle(M) so subclasses don't need to rewrite their proc chains.
/obj/structure/bed/proc/afterbuckle(mob/M)
	return

/// CM13 bed.do_buckle(mob/target, mob/user) — bridges to TG user_buckle_mob.
/obj/structure/bed/proc/do_buckle(mob/target, mob/user)
	return user_buckle_mob(target, user)

/// CM13 bed.manual_unbuckle(mob/user) — bridges to TG user_unbuckle_mob.
/obj/structure/bed/proc/manual_unbuckle(mob/user)
	var/mob/living/M = LAZYACCESS(buckled_mobs, 1)
	if(!M)
		return null
	return user_unbuckle_mob(M, user)

/// CM13 bed.unbuckle() (no args) — bridges to TG unbuckle_all_mobs().
/obj/structure/bed/proc/unbuckle()
	return unbuckle_all_mobs()

/// TG post_buckle_mob override — sync buckled_mob alias, then forward to
/// CM13 afterbuckle(M) so existing subclasses work without rewrite.
/obj/structure/bed/post_buckle_mob(mob/living/M)
	. = ..()
	buckled_mob = LAZYACCESS(buckled_mobs, 1)
	afterbuckle(M)

/// TG post_unbuckle_mob override — sync buckled_mob alias (now likely null),
/// then forward to CM13 afterbuckle(M) for cleanup logic.
/obj/structure/bed/post_unbuckle_mob(mob/living/M)
	. = ..()
	buckled_mob = LAZYACCESS(buckled_mobs, 1)
	afterbuckle(M)

// ============================================================================
// CLICK HANDLER SHIM — CM13 /atom/proc/clicked(mob/user, list/mods).
// TG uses COMSIG_ATOM_ATTACKBY and shift-click signal handlers instead.
// ============================================================================

/atom/proc/clicked(mob/user, list/mods)
	return

// ============================================================================
// MOB VIEW RESET SHIM — CM13 /mob/proc/reset_view(atom/A) → TG reset_perspective.
// TG has no reset_view proc; reset_perspective is the native equivalent.
// ============================================================================

/// CM13 mob.reset_view(atom/A) — bridges to TG mob.reset_perspective(atom/A).
/// Call with no args (null) to reset the eye to the mob's default.
/mob/proc/reset_view(atom/A)
	return reset_perspective(A)

// ============================================================================
// CLIENT PIXEL OFFSET SHIMS — CM13 client.set_pixel_x / set_pixel_y → TG
// client.pixel_x / pixel_y direct vars.
// ============================================================================

/client/proc/set_pixel_x(px)
	pixel_x = px

/client/proc/set_pixel_y(py)
	pixel_y = py

// ============================================================================
// ITEM ZOOM SHIM — CM13 /obj/item.zoom var + /obj/item/proc/zoom(mob/user).
// TG has a different scope/zoom system. Stub var + no-op proc for compile
// compat so ported vehicle gunner-seat code can iterate held items and call
// zoom() without crashing.
// ============================================================================

/obj/item/var/zoom = FALSE

/obj/item/proc/zoom(mob/user)
	return

/mob/proc/is_mob_incapacitated(ignore_flags = FALSE)
	return HAS_TRAIT(src, TRAIT_INCAPACITATED)

/obj/vehicle/multitile/proc/handle_click(mob/living/user, atom/A, list/mods)
	return

/obj/vehicle/multitile/var/last_move_dir = SOUTH
/obj/vehicle/multitile/var/l_move_time = 0

/obj/structure/inflatable
	name = "inflatable stub"
	density = FALSE
	opacity = FALSE
	anchored = FALSE

/obj/structure/inflatable/proc/deflate(forced = FALSE)
	return

/proc/show_browser(mob/user, content, title, window_id, width = 0, height = 0, atom/source = null)
	var/datum/browser/popup = new(user, window_id, title, width, height)
	popup.set_content(content)
	popup.open()
	return
