//---VEHICLE TRAMPLE DAMAGE (xeno-related, commented out)---
// #define VEHICLE_TRAMPLE_DAMAGE_MIN 5
// #define VEHICLE_TRAMPLE_DAMAGE_TIER_1 22.5
// #define VEHICLE_TRAMPLE_DAMAGE_TIER_2 18
// #define VEHICLE_TRAMPLE_DAMAGE_TIER_3 13.5
// #define VEHICLE_TRAMPLE_DAMAGE_SPECIAL 10
// #define VEHICLE_TRAMPLE_DAMAGE_APC_REDUCTION 1
// #define VEHICLE_TRAMPLE_DAMAGE_REDUCTION_ARMOR_MULT 2
// #define VEHICLE_TRAMPLE_DAMAGE_OVERDRIVE_BUFF 5

//---MISC DEFINES---
/// Turf flag for hull walls (used by vehicle bump code)
#define TURF_HULL (1<<0)

/// Squeeze under vehicles flag (xeno-related, kept for mob_flags compat)
#define SQUEEZE_UNDER_VEHICLES (1<<5)

/// Throw speed for vehicle interior crash effects
#define SPEED_VERY_FAST 3

/// CM13 status effect aliases → TG equivalents
#define STUN EFFECT_STUN
#define WEAKEN EFFECT_KNOCKDOWN
#define PARALYZE EFFECT_PARALYZE

/// CM13 intent defines (TG uses combat_mode boolean instead)
#define INTENT_HELP "help"
#define INTENT_HARM "harm"
#define INTENT_GRAB "grab"
#define INTENT_DISARM "disarm"

/// CM13 gun firemode defines (TG uses a different gun system)
#define GUN_FIREMODE_SEMIAUTO "semi-auto"
#define GUN_FIREMODE_BURSTFIRE "burstfire"
#define GUN_FIREMODE_AUTOMATIC "automatic"

/// CM13 autofire return values
#define AUTOFIRE_CONTINUE 1
#define AUTOFIRE_ABORT 0

/// CM13 gun signals (not in TG)
#define COMSIG_GUN_STOP_FIRE "gun_stop_fire"
#define COMSIG_GUN_FIRE "gun_fire"
#define COMSIG_GUN_AUTOFIREDELAY_MODIFIED "gun_autofiredelay_modified"
#define COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED "gun_burst_shot_delay_modified"

/// CM13 bullet signal
#define COMSIG_BULLET_USER_EFFECTS "bullet_user_effects"

/// CM13 HAS_FLAG macro
#define HAS_FLAG(flags, flag) ((flags) & (flag))

/// CM13 weight class aliases
#define SIZE_LARGE WEIGHT_CLASS_BULKY
#define SIZE_NORMAL WEIGHT_CLASS_NORMAL
#define SIZE_SMALL WEIGHT_CLASS_SMALL
#define SIZE_HUGE WEIGHT_CLASS_HUGE
#define SIZE_MASSIVE WEIGHT_CLASS_GIGANTIC

/// CM13 TRAIT_TOOL_BLOWTORCH — TG doesn't have this trait
#define TRAIT_TOOL_BLOWTORCH "tool_blowtorch"

/// CM13 CONSCIOUS alias
#define CONSCIOUS STABLE

/// CM13 floor/ceil — TG has these as reserved words, use round() instead.
/// Note: Cannot use #define floor(x) as it breaks TG code that uses "floor" as a var name.
/// Vehicle code should use round() directly instead of floor().

/// CM13 LAZYISIN — TG doesn't have this macro
#define LAZYISIN(list, item) (item in list)

/// CM13 COOLDOWN_SECONDSLEFT
#define COOLDOWN_SECONDSLEFT(src, cd) ((cd - world.time) / 10)

/// CM13 UNCONSCIOUS alias
#define UNCONSCIOUS HARD_CRIT

/// CM13 SS_UNUSED — suppress unused variable warnings
#define SS_UNUSED(x) (void) (x)

/// CM13 QDEL_NULL_LIST — nulls and qdel's all entries in a list, then nulls the list
#define QDEL_NULL_LIST(L) if(L) { for(var/I in L) qdel(I); L = null; }

/// CM13 TRAIT_TOOL_CROWBAR — TG uses iscrowbar() instead
#define TRAIT_TOOL_CROWBAR "tool_crowbar"

/// CM13 COMSIG_PARENT_QDELETING alias
#define COMSIG_PARENT_QDELETING COMSIG_QDELETING

// ============================================================================
// CM13 SKILL SYSTEM — TG doesn't have skillcheck().
// These are stub defines for compilation; skillcheck() always returns TRUE.
// ============================================================================

#define SKILL_ENGINEER "engineer"
#define SKILL_VEHICLE "vehicle"
#define SKILL_ENGINEER_TRAINED 3
#define SKILL_ENGINEER_NOVICE 2
#define SKILL_VEHICLE_CREWMAN 2

// ============================================================================
// CM13 GUN FIREMODES — TG uses different system
// ============================================================================

#define GUN_FIREMODE_SEMIAUTO "semi_auto"
#define GUN_FIREMODE_AUTO "auto"
#define GUN_FIREMODE_BURST "burst"

// ============================================================================
// CM13 MOVEMENT SPEED
// ============================================================================

#define SPEED_FAST 2
#define SPEED_SLOW 4

//---FACTION (placeholder, adapt to TG faction system as needed)---
#define FACTION_MARINE "marine"

//---ACCESS (placeholder, adapt to TG access system as needed)---
#define ACCESS_MARINE_CREWMAN "access_marine_crewman"
#define ACCESS_MARINE_COMMAND "access_marine_command"
#define ACCESS_MARINE_BRIG "access_marine_brig"

//---MINIMAP (placeholder, TG does not have SSminimaps)---
#define MINIMAP_FLAG_USCM 1
