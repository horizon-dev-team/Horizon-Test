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
#define COMSIG_GUN_INTERRUPT_FIRE "gun_interrupt_fire"
#define COMSIG_GUN_AUTOFIREDELAY_MODIFIED "gun_autofiredelay_modified"
#define COMSIG_GUN_BURST_SHOT_DELAY_MODIFIED "gun_burst_shot_delay_modified"
#define COMSIG_GUN_RECALCULATE_ATTACHMENT_BONUSES "gun_recalculate_attachment_bonuses"

/// CM13 bullet signal
#define COMSIG_BULLET_USER_EFFECTS "bullet_user_effects"

/// CM13 ARC antenna signal
#define COMSIG_ARC_ANTENNA_TOGGLED "arc_antenna_toggled"

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

/// CM13 CONSCIOUS alias — TG uses STABLE=0 (full health, no critical state)
#define CONSCIOUS STABLE

/// CM13 floor/ceil — TG has these as reserved words, use round() instead.
/// Note: Cannot use #define floor(x) as it breaks TG code that uses "floor" as a var name.
/// Vehicle code should use round() directly instead of floor().

/// CM13 LAZYISIN — TG doesn't have this macro
#define LAZYISIN(list, item) (item in list)

/// CM13 COOLDOWN_SECONDSLEFT
#define COOLDOWN_SECONDSLEFT(src, cd) ((cd - world.time) / 10)

/// CM13 UNCONSCIOUS alias — TG uses HARD_CRIT=2 (knocked out)
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
#define SKILL_VEHICLE_SMALL 1
#define SKILL_VEHICLE_LARGE 3
#define SKILL_VEHICLE_DEFAULT 0
#define SKILL_POLICE "police"
#define SKILL_POLICE_SKILLED 3

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
#define MINIMAP_FLAG_XENO 2

// ============================================================================
// CM13 JOB DEFINES — TG uses different job system.
// These are string constants used for role-restricted slots in vehicle_locker.
// Replace with TG job names where appropriate.
// ============================================================================

#define JOB_CREWMAN "Crewman"
#define JOB_UPP_CREWMAN "UPP Crewman"
#define JOB_TANK_CREW "Tank Crew"
#define JOB_PMC_CREWMAN "PMC Crewman"
#define JOB_ARMY_TANK "Army Tank Crew"
#define JOB_CMO "Chief Medical Officer"
#define JOB_DOCTOR "Medical Doctor"
#define JOB_PMC_LEAD_INVEST "PMC Lead Investigator"
#define JOB_PMC_LEADER "PMC Leader"
#define JOB_PMC_SYNTH "PMC Synthetic"
#define JOB_WY_COMMANDO_LEADER "W-Y Commando Leader"

// ============================================================================
// CM13 MOB SIZE ALIASES — TG uses different naming
// ============================================================================

#define MOB_SIZE_XENO MOB_SIZE_HUMAN
#define MOB_SIZE_IMMOBILE MOB_SIZE_HUGE
#define MOB_SIZE_XENO_SMALL MOB_SIZE_SMALL

// ============================================================================
// CM13 LAYER ALIASES — TG uses different layer naming
// ============================================================================

#define WALL_LAYER WALL_OBJ_LAYER
#define WINDOW_LAYER ABOVE_WINDOW_LAYER
#define FLY_LAYER 5
#define ABOVE_FLY_LAYER 5.5
#define ABOVE_XENO_LAYER LARGE_MOB_LAYER
#define INTERIOR_DOOR_LAYER 3.45
#define INTERIOR_WALL_SOUTH_LAYER 5.0

// ============================================================================
// CM13 DO_AFTER FLAGS — TG uses timed_action_flags with IGNORE_* constants
// ============================================================================

#define INTERRUPT_ALL NONE
#define INTERRUPT_NO_NEEDHAND IGNORE_HELD_ITEM
#define BUSY_ICON_GENERIC null
#define BUSY_ICON_HOSTILE null
#define BUSY_ICON_FRIENDLY null
#define BUSY_ICON_BUILD null
#define BEHAVIOR_IMMOBILE NONE

// ============================================================================
// CM13 RESISTANCE FLAGS
// ============================================================================

#define UNACIDABLE FIRE_PROOF

// ============================================================================
// CM13 TRAIT DEFINES — not in TG
// ============================================================================

#define DOUBLE_SEATS_TRAIT "double_seats"

// ============================================================================
// CM13 EXPLOSION THRESHOLDS
// ============================================================================

#define EXPLOSION_THRESHOLD_LOW 60
#define EXPLOSION_THRESHOLD_MEDIUM 180
#define EXPLOSION_FALLOFF_SHAPE_LINEAR 1

// ============================================================================
// CM13 AMMO FLAGS — TG uses different projectile system
// ============================================================================

#define AMMO_HITS_TARGET_TURF (1<<0)
#define AMMO_EXPLOSIVE (1<<1)

// ============================================================================
// CM13 MODE/MODIFIER MACROS — TG doesn't have these
// ============================================================================

#define MODE_HAS_MODIFIER(x) FALSE

// ============================================================================
// CM13 XENO CONSTANTS — kept for compilation; xeno blocks commented out in code
// ============================================================================

#define XENO_NO_DELAY_ACTION 0
#define TAILSTAB_COOLDOWN_NONE 0
#define TAILSTAB_COOLDOWN_LOW 5 SECONDS
#define TAILSTAB_COOLDOWN_NORMAL 10 SECONDS
#define CHAT_TYPE_XENO_COMBAT "xeno_combat"

// ============================================================================
// CM13 ADMIN HELPER MACROS
// ============================================================================

#define WRAP_STAFF_LOG(user, msg) msg

// ============================================================================
// CM13 MATH/HELPER MACROS
// ============================================================================

#define Get_Angle(a, b) get_angle(a, b)
#define ISINRANGE_EX(val, low, high) ((val) >= (low) && (val) <= (high))
#define NO_BLOCKED_MOVEMENT 0

// ============================================================================
// CM13 FLAGS_ATOM ALIAS — TG uses obj_flags
// ============================================================================

#define flags_atom obj_flags
#define NOINTERACT NONE
#define USES_HEARING (1<<9)

// ============================================================================
// CM13 HEALTH ALIAS — TG uses atom_integrity
// ============================================================================

// Note: do NOT #define health atom_integrity — this breaks /obj/vehicle and
// many other TG types that legitimately have a `health` var. Instead, refactor
// vehicle code that uses `health` to use `get_integrity()` / `atom_integrity`.

#define CAN_PICKUP(user, target) (target.Adjacent(user))
#define COMSIG_MOB_MOUSEDOWN "mob_mousedown"
#define COMSIG_MOB_MOUSEUP "mob_mouseup"
#define COMSIG_MOB_MOUSEDRAG "mob_mousedrag"
#define COMSIG_MOB_LOGGED_IN COMSIG_MOB_LOGIN
