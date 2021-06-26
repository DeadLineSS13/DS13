/mob/living
	see_in_dark = 255
	see_invisible = SEE_INVISIBLE_LIVING

	//Health and life related vars
	var/max_health = 100 //Maximum health that should be possible.
	var/health = 100 	//A mob's health
	var/pain_shock_threshold = 30	//Pain above this threshold will cause the mob to start going into shock
	var/lasting_damage = 0	//Damage which doesn't heal under normal circumstances

	var/ranged_accuracy_modifier = 0	//Added or removed from accuracy when using ranged weapons

	biomass = 1	//How much biomass is this mob worth when absorbed

	var/hud_updateflag = 0

	//Damage related vars, NOTE: THESE SHOULD ONLY BE MODIFIED BY PROCS // what a joke
	//var/bruteloss = 0 //Brutal damage caused by brute force (punching, being clubbed by a toolbox ect... this also accounts for pressure damage)
	//var/oxyloss = 0   //Oxygen depravation damage (no air in lungs)
	//var/toxloss = 0   //Toxic damage caused by being poisoned or radiated
	//var/fireloss = 0  //Burn damage caused by being way too hot, too cold or burnt.
	//var/halloss = 0   //Hallucination damage. 'Fake' damage obtained through hallucinating or the holodeck. Sleeping should cause it to wear off.

	var/last_special = 0 //Used by the resist verb, likely used to prevent players from bypassing next_move by logging in/out.

	var/t_phoron = null
	var/t_oxygen = null
	var/t_sl_gas = null
	var/t_n2 = null

	var/now_pushing = null
	var/mob_bump_flag = 0
	var/mob_swap_flags = 0
	var/mob_push_flags = 0
	var/mob_always_swap = 0

	var/mob/living/cameraFollow = null
	var/list/datum/action/actions = list()

	var/update_slimes = 1
	var/silent = null 		// Can't talk. Value goes down every life proc.
	var/on_fire = 0 //The "Are we on fire?" var
	var/fire_stacks

	var/failed_last_breath = 0 //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.
	var/possession_candidate // Can be possessed by ghosts if unplayed.

	var/eye_blind = null	//Carbon
	var/eye_blurry = null	//Carbon
	var/ear_damage = null	//Carbon
	var/stuttering = null	//Carbon
	var/slurring = null		//Carbon

	var/job = null//Living
	var/list/obj/aura/auras = null //Basically a catch-all aura/force-field thing.

	var/obj/screen/cells = null

	var/last_resist = 0



	var/attack_speed_factor	=	1	//Multiplier on attackspeed. Used as a divisor on unarmed attack delays, and certain ability cooldowns
	var/incoming_damage_mult = 1	//Multiplier on all damage recieved, regardless of source