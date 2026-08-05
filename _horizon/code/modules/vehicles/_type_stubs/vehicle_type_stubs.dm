// Type stubs for CM13 types that don't exist in TG.
// These are minimal empty/placeholder types so ported CM13 vehicle code
// can reference them via istype() without runtime errors.
// All stubs return FALSE from istype() checks against actual TG mobs/objects.

// ============================================================================
// XENO TYPES — TG has no xenomorphs
// ============================================================================

/// CM13 /mob/living/carbon/xenomorph — empty stub. istype() against this
/// always returns FALSE for any TG mob.
/mob/living/carbon/xenomorph
	name = "xenomorph stub"

// ============================================================================
// XENO EFFECTS — TG has no xeno-related effects
// ============================================================================

/obj/effect/xenomorph
	name = "xeno effect stub"

/obj/effect/xenomorph/spray
	name = "xeno spray stub"

/obj/effect/alien
	name = "alien effect stub"

/obj/effect/alien/weeds
	name = "alien weeds stub"

/obj/effect/blocker
	name = "blocker effect stub"

/obj/effect/blocker/water
	name = "water blocker stub"

/obj/effect/blocker/water/toxic
	name = "toxic water blocker stub"

// ============================================================================
// BARRICADE SUBTYPES — TG has different barricade structure
// ============================================================================

/obj/structure/barricade/plasteel
	name = "plasteel barricade stub"

/obj/structure/barricade/sandbags
	name = "sandbag barricade stub"

/obj/structure/barricade/metal
	name = "metal barricade stub"

/obj/structure/barricade/deployable
	name = "deployable barricade stub"

// ============================================================================
// MISC CM13 TYPES
// ============================================================================

/// CM13 vehicle clamp item — not ported; stub for compile
/obj/item/vehicle_clamp
	name = "vehicle clamp stub"
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "vehicle_clamp"

/// CM13 powerloader structure stub — referenced as a typed var on the
/// powerloader_clamp stub. TG has no powerloader; this is just an empty
/// type so the var declaration compiles.
/obj/structure/powerloader
	name = "powerloader stub"

/// CM13 powerloader clamp — used to install/remove massive hardpoints.
/// TG has no powerloader. Stub exists so BYOND compiler can resolve the
/// `var/obj/item/powerloader_clamp/PC = O` casts in multitile_hardpoints.dm.
/// `ispowerclamp()` always returns FALSE, so the cast blocks are never
/// entered at runtime — but the type must still exist for compilation.
/obj/item/powerloader_clamp
	name = "powerloader clamp stub"
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "vehicle_clamp"
	/// Hardpoint currently held by the clamp (CM13 var)
	var/obj/item/hardpoint/loaded = null
	/// Powerloader this clamp is attached to (CM13 var, unused in TG)
	var/obj/structure/powerloader/linked_powerloader = null

/// CM13 powerloader clamp grab_object — no-op in TG
/obj/item/powerloader_clamp/proc/grab_object(mob/user, obj/item/target, slot_key)
	return

/// CM13 /obj/structure/prop/vehicle — base for vehicle props (chassis overlays etc)
/obj/structure/prop/vehicle
	name = "vehicle prop"
	anchored = TRUE

/// CM13 /obj/structure/prop/vehicle/arc — ARC chassis overlay
/obj/structure/prop/vehicle/arc
	name = "ARC chassis"
	icon = 'icons/obj/vehicles/vehicles.dmi'
	layer = ABOVE_NORMAL_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

// ============================================================================
// CM13 AMMO DATUM STUBS — TG uses different projectile system
// ============================================================================

/datum/ammo
	var/name = "ammo stub"
	var/flags_ammo_behavior = 0

/datum/ammo/bullet
	name = "bullet ammo stub"

/datum/ammo/bullet/shrapnel
	name = "shrapnel ammo stub"

// ============================================================================
// CM13 HARDDRIVE AMMO MAGAZINE STUB — referenced in hardpoint.dm Entered()
// ============================================================================

/obj/item/ammo_magazine/hardpoint
	name = "hardpoint ammo magazine stub"
	icon = 'icons/obj/weapons/guns/ammo.dmi'
	icon_state = "38"
	var/default_ammo = /datum/ammo/bullet
	var/current_rounds = 0
	var/max_rounds = 100

/// CM13 projectile trait apply proc — no-op in TG
/obj/projectile/proc/apply_bullet_trait(list/trait)
	return

/// CM13 projectile generate_bullet — no-op in TG
/obj/projectile/proc/generate_bullet(datum/ammo/A)
	return

// ============================================================================
// CM13 AUTOFIRE COMPONENT STUB — TG has different gun system
// ============================================================================

/datum/component/automatedfire
	var/fire_delay = 0
	var/burst_delay = 0
	var/burst_amount = 1

/datum/component/automatedfire/autofire
	fire_delay = 1

// ============================================================================
// CM13 PROJECTILE VARS — TG projectile doesn't have these
// ============================================================================

/// CM13 projectile.scatter — TG uses `spread` instead. Stub for compat.
/obj/projectile/var/scatter = 0

/// CM13 projectile.ammo — TG uses a different ammo system. Stub datum ref.
/obj/projectile/var/datum/ammo/ammo = null

/// CM13 projectile.projectile_override_flags — TG has no equivalent. Stub.
/obj/projectile/var/projectile_override_flags = 0

// ============================================================================
// CM13 HARDPOINT HOLDER STUB — full impl in hardpoints/holder/holder.dm
// (currently commented out in _vehicle_includes.dm). Minimal stub so istype()
// checks against /obj/item/hardpoint/holder in active code compile.
// If holder.dm is uncommented later, this stub merges harmlessly with the
// full implementation (no var redefinitions here — only inherits from parent).
// ============================================================================

/obj/item/hardpoint/holder
	name = "holder hardpoint stub"

// ============================================================================
// CM13 EXPLOSIVE GRENADE STUB — TG has no /obj/item/explosive path; TG uses
// /obj/item/grenade with different vars/proc names. Stub exists so the typed
// var declaration `var/obj/item/explosive/grenade/nade = object` in
// doors.dm compiles. istype() against this stub always returns FALSE for any
// real TG item, so the grenade-throwing code body in doors.dm is unreachable
// at runtime but must still compile.
// ============================================================================

/obj/item/explosive
	name = "explosive stub"

/obj/item/explosive/grenade
	name = "grenade stub"
	/// CM13 antigrief_protection — TRUE if the grenade is blocked in safe areas.
	var/antigrief_protection = FALSE
	/// CM13 active — TRUE once the grenade is primed.
	var/active = FALSE

/// CM13 grenade.activate(mob/user) — primes the grenade. No-op in stub.
/obj/item/explosive/grenade/proc/activate(mob/user)
	return

// ============================================================================
// CM13 GRAB ITEM STUB — TG handles grabbing via /datum/component/grab and
// the pulling system, not /obj/item/grab. CM13 doors.dm checks for grab items
// in hands to drag atoms through vehicle doors. Stub exists so the typed var
// `var/obj/item/grab/G = M.get_inactive_hand()` compiles. Since istype()
// against this stub always returns FALSE for any real TG held item, the
// drag-through-door code body is unreachable at runtime.
// ============================================================================

/obj/item/grab
	name = "grab stub"
	/// CM13 grab.grabbed_thing — the atom being dragged via this grab item.
	var/atom/movable/grabbed_thing = null
