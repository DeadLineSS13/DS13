/obj/structure/corruption_node
	anchored = TRUE
	layer = ABOVE_OBJ_LAYER	//Make sure nodes draw ontop of corruption
	icon = 'icons/effects/corruption.dmi'
	var/marker_spawnable = TRUE	//When true, this automatically shows in the necroshop
	biomass = 10
	var/biomass_reclamation = 0.9
	var/reclamation_time = 10 MINUTES
	var/requires_corruption = TRUE
	var/random_rotation = TRUE	//If true, set rotation randomly on spawn

	var/placement_type = /datum/click_handler/placement/necromorph
	var/placement_location = PLACEMENT_FLOOR


	var/dummy = FALSE

	default_rotation = 0
	max_health = 100
	resistance = 0
	var/regen = 1
	var/degen = 0.5

	var/randpixel = 0

	var/processing = FALSE



/obj/structure/corruption_node/Initialize()
	.=..()
	if (!isturf(loc))
		dummy = TRUE


	update_icon()
	if (!dummy)
		animate_fade_in()

	start_processing()


/obj/structure/corruption_node/get_biomass()
	return 0	//This is not edible

/obj/structure/corruption_node/Destroy()
	if (!dummy && SSnecromorph.marker && biomass_reclamation)
		SSnecromorph.marker.add_biomass_source(src, biomass*biomass_reclamation, reclamation_time, /datum/biomass_source/reclaim)

	.=..()


/obj/structure/corruption_node/update_icon()
	.=..()
	var/matrix/M = matrix()
	M = M.Scale(default_scale)	//We scale up the sprite so it slightly overlaps neighboring corruption tiles
	M = turn(M, get_rotation())
	if (randpixel)
		pixel_x = default_pixel_x + rand_between(-randpixel, randpixel)
		pixel_y = default_pixel_y + rand_between(-randpixel, randpixel)
	transform = M


/obj/structure/corruption_node/proc/get_rotation()
	if (!random_rotation)
		return 0
	default_rotation = pick(list(0,45,90,135,180,225,270,315))//Randomly rotate it

	return default_rotation

/obj/structure/corruption_node/proc/get_blurb()

/obj/structure/corruption_node/proc/get_long_description()
	.="<b>Health</b>: [max_health]<br>"
	if (biomass)
		.+="<b>Biomass</b>: [biomass]kg[biomass_reclamation ? " . If destroyed, reclaim [biomass_reclamation*100]% biomass over [reclamation_time/600] minutes" : ""]<br>"
	if (requires_corruption)
		.+= SPAN_WARNING("Must be placed on a corrupted tile <br>")
	.+= "<br><br>"
	.+= get_blurb()
	.+="<br><hr>"

/obj/structure/corruption_node/Process()
	if (turf_corrupted(src, TRUE))
		regenerate()
		if (can_stop_processing())
			processing = FALSE
			return PROCESS_KILL
	else
		degenerate()

/obj/structure/corruption_node/proc/regenerate()
	health = clamp(health+regen, 0, max_health)

/obj/structure/corruption_node/proc/degenerate()
	take_damage(degen, BRUTE, null, null, bypass_resist = TRUE)

/obj/structure/corruption_node/take_damage(var/amount, var/damtype = BRUTE, var/user, var/used_weapon, var/bypass_resist = FALSE)
	.=..()
	if (.)
		start_processing()


/*
	Process Handling
*/
/obj/structure/corruption_node/proc/start_processing()
	if (!processing)
		processing = TRUE
		START_PROCESSING(SSobj, src)

/obj/structure/corruption_node/proc/can_stop_processing()
	if (health < max_health)
		return FALSE

	if (!turf_corrupted(src, TRUE))
		return FALSE

	return TRUE


/obj/structure/corruption_node/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if (istype(mover, /obj/effect/vine/corruption))
		return TRUE

	.=..()

//Checks if a a structure about to be placed would overlap with ourselves. Return false to block the placement, true to allow it
/obj/structure/corruption_node/proc/check_overlap(var/datum/click_handler/placement/P)
	if (placement_location == P.placement_location)
		return FALSE
	return TRUE