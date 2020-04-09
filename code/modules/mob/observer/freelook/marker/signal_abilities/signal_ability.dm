/*
	Signal abilities are "spells" that can be used by signals, and the marker, while in their observer modes.
	They cost psi energy, which is passively gained over time while in the right modes.

	Almost all signal abilities can only be cast upon tiles visible to the necrovision network.
	Many, more restrictive ones, can only be cast upon corrupted tiles. And often only when not visible to humans
*/



/datum/signal_ability
	var/name = "Ability"

	var/id = "ability"	//ID should be unique and all lowercase

	var/desc = "Does stuff!"
	var/long_desc = ""

	//Cost of casting it. Can be zero
	var/energy_cost = 60

	var/base_type = /datum/signal_ability	//Used to prevent abstract parent classes from showing up in autoverbs

	//If the user clicks something which isn't a valid target, we'll search in this radius around the clickpoint to find a valid target.
	//A value of zero still works, and will search only in the clicked turf. Set to null to disable autotargeting.
	var/autotarget_range = 1

	//If true, autotargeting only selects things in view of the clicked place. If false, things in range are selected regardless of LOS
	var/target_view = FALSE

	//Many spells have cooldowns in addition to costs
	var/cooldown = 10 SECONDS

	//What types of atom we are allowed to target with this ability. This will be used for autotargeting
	//Any number of valid types can be put in this list
	var/target_types = list(/turf)

	//A string telling the user what to click on/near
	var/target_string = "any visible tile"

	//If set to true or false, this requires the target to be an ally or not-ally of the user, respectively,
	//Only used when targeting mobs. Leave it null to disable this behaviour
	var/allied_check = null


	//If true, can only be cast on turfs currently in the necrovision network.
	//When false, spells can be cast onto the blackspace outside it. Not very useful but has some potential applications
	//This setting is completely ignored if require_corruption is set true, they are exclusive
	var/require_necrovision = TRUE

	//When true, the turf which contains/is the target must have corruption on it.
	var/require_corruption = FALSE

	//When true, the turf which contains/is the target must not be visible to any conscious crewmember
	//UNIMPLEMENTED//var/LOS_blocked	=	TRUE

	//When set to a number, the spell must be cast at least this distance away from a conscious crewmember
	//UNIMPLEMENTED//var/distance_blocked = 1

	//If true, this spell can only be cast after the marker has activated
	//If false, it can be cast anytime from roundstart
	var/marker_active_required = FALSE


	//How many targets this spell needs. This may allow casting on multiple things at once, or tracing a path. Default 1
	//UNIMPLEMENTED//var/num_targets


	//If true, signals cannot cast this spell. Only the marker player can do it
	var/marker_only	= FALSE

	//Targeting Handling:
	//--------------------------
	var/targeting_method	=	TARGET_CLICK

	//What type of click handler this uses to select a target, if any
	//Only used when targeting method is not self
	//If not specified, defaults will be used for click and placement
	var/click_handler_type =	null

	//Atom used for the preview image of placement handler, if we're using that
	var/placement_atom = null

	//Does placement handler snap-to-grid?
	var/placement_snap = TRUE







/*----------------------------------------------
	Overrides:
	Override these in subclasses to do things
-----------------------------------------------*/
//This does nothing in the base class, override it and put spell effects here
/datum/signal_ability/proc/on_cast(var/mob/user, var/atom/target, var/list/data)
	return

//Return true if the passed thing is a valid target
/datum/signal_ability/proc/special_check(var/atom/thing)
	return TRUE


/*----------------------------------------------------------------------
	Core Code: Be very careful about overrriding these, best not to
----------------------------------------------------------------------*/
//Entrypoint to this code, called when user clicks the button to start a spell.
//This code creates the click handler
/datum/signal_ability/proc/start_casting(var/mob/user)

	var/check = can_cast_now(user)
	//Validate before casting
	if (check != TRUE)
		to_chat(user, SPAN_WARNING(check))
		return

	to_chat(user, SPAN_NOTICE("Now Casting [name], click on a target."))
	switch(targeting_method)
		if (TARGET_CLICK)
			//We make a target clickhandler, this callback is sent through to the handler's /New. User will be maintained as the first argument
			//When the user clicks, it will call target_click, passing back the user, as well as the thing they clicked on, and clickparams
			var/datum/click_handler/CH = user.PushClickHandler((click_handler_type ? click_handler_type : /datum/click_handler/target), CALLBACK(src, /datum/signal_ability/proc/target_click, user))
			CH.id = "[src.type]"
		if (TARGET_PLACEMENT)
			//Make the placement handler, passing in atom to show. Callback is propagated through and will link its clicks back here
			var/datum/click_handler/CH = create_ability_placement_handler(user, placement_atom, click_handler_type ? click_handler_type : /datum/click_handler/placement/ability, placement_snap, require_corruption, CALLBACK(src, /datum/signal_ability/proc/placement_click, user))
			CH.id = "[src.type]"
		if (TARGET_SELF)
			select_target(user, user)



//Path to the end of the cast
/datum/signal_ability/proc/finish_casting(var/mob/user, var/atom/target,  var/list/data)
	//Pay the energy costs
	if (!pay_cost(user))
		//TODO: Abort casting, we failed
		return


	//And do the actual effect of the spell
	on_cast(user, target,  data)

	//TODO 1: Call a cleanup/abort proc to finish
	stop_casting(user)

//This is called after finish, or at any point during casting if things fail.
//It deletes clickhandlers, cleans up, etc.
/datum/signal_ability/proc/stop_casting(var/mob/user)

	//Search the user's clickhandlers for any which have an id matching our type, indicating we put them there. And remove those
	for (var/datum/click_handler/CH in user.GetClickHandlers())
		if (CH.id == "[src.type]")
			user.RemoveClickHandler(CH)


//Called from the click handler when the user clicks a potential target.
//Data is an associative list of any miscellaneous data. It contains the direction for placement handlers
/datum/signal_ability/proc/select_target(var/mob/user, var/candidate,  var/list/data)
	var/newtarget = candidate
	if (!is_valid_target(newtarget))	//If its not right, then find a better one
		newtarget = null
		var/list/allied_data = null
		if (!isnull(allied_check))
			allied_data = list(user, allied_check)
		var/visualnet = null
		if (require_necrovision)
			visualnet = GLOB.necrovision

		var/list/things = get_valid_target(candidate, autotarget_range, target_types,	allied_data, visualnet, require_corruption, target_view, 1, CALLBACK(src, /datum/signal_ability/proc/special_check))

		if (things.len)
			newtarget = things[1]
	if (!newtarget)
		return FALSE

	.=TRUE
	//TODO 2:	Add add a flag to not instacast here

	finish_casting(user, newtarget,  data)




/*
	Returns a paragraph or two of text explaining what this spell does
*/
/datum/signal_ability/proc/get_long_description(var/mob/user)
	if (long_desc)
		return long_desc
	.="<b>Cost</b>: [energy_cost]<br>"
	if (cooldown)
		.+="<b>Cooldown</b>: [descriptive_time(cooldown)]<br>"
	.+="<b>Target</b>: [target_string]<br>"
	if (autotarget_range)
		.+="<b>Autotarget Range</b>: [autotarget_range]%<br>"
	.+= desc
	long_desc = .


/*
	Actually deducts energy, sets cooldowns, and makes any other costs as a result of casting. Returns true if all succeed
*/
/datum/signal_ability/proc/pay_cost(var/mob/user)
	.= FALSE


	//TODO 1: Set cooldown here


	//Pay energy cost last
	var/datum/player/P = user.get_player()
	if (energy_cost)
		var/datum/extension/psi_energy/PE = user.get_energy_extension()
		if (!PE)
			return

		if (!(PE.can_afford_energy_cost(energy_cost, src)))
			return

		PE.change_energy(-energy_cost)

	return TRUE







/*-----------------------------
	Click Handling
------------------------------*/

//Called from a click handler using the TARGET_CLICK method
/datum/signal_ability/proc/target_click(var/mob/user, var/atom/target, var/params)
	return select_target(user, target)




/datum/signal_ability/proc/placement_click(var/mob/user, var/atom/target, var/list/data)
	return select_target(user, target,  data)








/*---------------------------
	Safety Checks
----------------------------*/

/*
	Checks whether the given user is currently able to cast this spell.
	This is called before casting starts, so no targeting data yet. It checks:
		-Available energy
		-Correct mob type

	This proc will either return TRUE if no problem, or an error message if there is a problem
*/
/datum/signal_ability/proc/can_cast_now(var/mob/user)
	.=is_valid_user(user)

	if (!.)
		return

	//var/datum/player/P = user.get_player()
	if (energy_cost)
		var/datum/extension/psi_energy/PE = user.get_energy_extension()
		if (!PE)
			return "You have no energy!"

		if (!(PE.can_afford_energy_cost(energy_cost, src)))
			return "Insufficient energy."


	//TODO 1: Check cooldown


/*
	Checks whether the user will be able to cast this spell in the near future, without outside assistance or changing circumstances
	This is mainly used for deciding whether or not to add it to our spell list
	Checks:
		-Correct mob type
		-Marker activity requirement

	Does not check energy cost, cooldown, or other ephemeral qualities

*/
/datum/signal_ability/proc/is_valid_user(var/mob/user)
	if (user)	//If there's no user, maybe we're casting it via script. Just let it through
		return TRUE

		if (marker_only && !is_marker_master(user))
			return FALSE

	if (marker_active_required)
		var/obj/machinery/marker/M = get_marker()
		if (M && !M.active)
			return FALSE

	return FALSE

//Does a lot of checking to see if the specified target is valid
/datum/signal_ability/proc/is_valid_target(var/atom/thing)
	var/correct_type = FALSE
	for (var/typepath in target_types)
		if (istype(thing, typepath))
			correct_type = TRUE
			break

	if (!correct_type)
		return FALSE

	if (!special_check(thing))
		return FALSE

	var/turf/T = get_turf(thing)
	if (require_corruption)
		//Since corrupted tiles are always visible to necrovision, we dont check vision if corruption is required
		if (!turf_corrupted(T))
			return FALSE
	else if (require_necrovision)
		if (!T.is_in_visualnet(GLOB.necrovision))
			return FALSE

	//TODO 1: Check allied status



	return TRUE








/client/verb/cast_ability(var/aname as text)
	set name = "Cast Ability"
	set category = "Debug"

	aname = lowertext(aname)
	var/datum/signal_ability/SA = GLOB.signal_abilities[aname]
	if (SA)
		SA.start_casting(mob)