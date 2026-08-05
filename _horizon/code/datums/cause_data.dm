// CM13 /datum/cause_data — minimal stub for damage attribution.
// In CM13 this datum tracks who/what caused damage (mob, name, weapon, etc.)
// TG uses a different explosion/damage attribution system.
// This stub allows ported CM13 vehicle code to compile.

/datum/cause_data
	var/cause_name = ""
	var/mob/attacker = null

/datum/cause_data/New(name, mob/attacker)
	cause_name = name
	src.attacker = attacker

/// CM13 create_cause_data(name, mob) — factory proc
/proc/create_cause_data(name, mob/attacker = null)
	return new /datum/cause_data(name, attacker)
