/var/obj/effect/lobby_image = new/obj/effect/lobby_image()

/obj/effect/lobby_image
	name = "Baystation12"
	desc = "This shouldn't be read."
	screen_loc = "WEST,SOUTH"
	var/change_interval = 1 MINUTE
	var/fade_time = 2 SECOND	//This fade time is used twice, so effectively doubled

/obj/effect/lobby_image/Initialize()
	icon = GLOB.using_map.lobby_icon

	var/known_icon_states = icon_states(icon)
	for(var/lobby_screen in GLOB.using_map.lobby_screens)
		if(!(lobby_screen in known_icon_states))
			error("Lobby screen '[lobby_screen]' did not exist in the icon set [icon].")
			GLOB.using_map.lobby_screens -= lobby_screen

	change_image()

	. = ..()

/obj/effect/lobby_image/proc/change_image()
	var/list/possible_options = GLOB.using_map.lobby_screens
	possible_options -= icon_state

	if (possible_options.len)
		fade_out()
		sleep(fade_time)



		icon_state = pick(GLOB.using_map.lobby_screens)


		fade_in()
		sleep(fade_time)
		addtimer(CALLBACK(src, /obj/effect/lobby_image/proc/change_image), change_interval)

/obj/effect/lobby_image/proc/fade_out()
	animate(src, color = "#000000", time = fade_time)


/obj/effect/lobby_image/proc/fade_in()
	animate(src, color = "#FFFFFF", time = fade_time)


/mob/new_player/Login()
	player_login()
	update_Login_details()	//handles setting lastKnownIP and computer_id for use by the ban systems as well as checking for multikeying

	//Here, before anything else, we'll handle signal continuance.
	//If this player is already marked as part of the necromorph team, it can mean only one thing: They disconnected while playing as a signal or master signal.
	//In that case we want to put them straight back into that body
	var/datum/player/P = get_player()
	if (P && P.is_necromorph)
		var/mob/observer/eye/signal/S = create_signal()

		var/turf/last_location = P.get_last_location()
		if (istype(S) && istype(last_location))
			S.forceMove(last_location)

		qdel(src)
		return


	if(join_motd)
		to_chat(src, "<div class=\"motd\">[join_motd]</div>")
	to_chat(src, "<div class='info'>Game ID: <div class='danger'>[game_id]</div></div>")

	if(!mind)
		mind = new /datum/mind(key)
		mind.active = 1
		mind.current = src

	loc = null
	client.screen += lobby_image
	my_client = client
	set_sight(sight|SEE_TURFS)
	GLOB.player_list |= src

	new_player_panel()
	spawn(40)
		if(client)
			handle_privacy_poll()
			client.playtitlemusic()
			maybe_send_staffwarns("connected as new player")

		var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
		var/decl/security_level/SL = security_state.current_security_level
		var/alert_desc = ""
		if(SL.up_description)
			alert_desc = SL.up_description
		to_chat(usr, "<span class='notice'>The alert level on the [station_name()] is currently: <font color=[SL.light_color_alarm]><B>[SL.name]</B></font>. [alert_desc]</span>")