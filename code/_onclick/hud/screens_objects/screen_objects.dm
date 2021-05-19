/obj/screen/oxygen
	name = "oxygen"
	icon_state = "oxy0"
	screen_loc = ui_oxygen


/obj/screen/fire
	name = "fire"
	icon_state = "fire0"
	screen_loc = ui_fire


/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'icons/mob/screen/midnight.dmi'
	icon_state = "running"
	screen_loc = ui_acti

/obj/screen/mov_intent/Click()
	//usr.toggle_move_intent()

/obj/screen/mov_intent/update_icon(mob/user)
	if(!user)
		return

	switch(user.m_intent)
		if(MOVE_INTENT_EXERTIVE)
			icon_state = "running"
		if(MOVE_INTENT_QUICK)
			icon_state = "running"
		if(MOVE_INTENT_DELIBERATE)
			icon_state = "walking"

/obj/screen/mov_intent/alien
	icon = 'icons/mob/screen1_alien.dmi'


/obj/screen/healths
	name = "health"
	icon_state = "health0"
	screen_loc = ui_health
	icon = 'icons/mob/screen/health.dmi'

/obj/screen/healths/alien
	icon = 'icons/mob/screen1_alien.dmi'
	screen_loc = ui_alien_health

/obj/screen/healths/robot
	icon = 'icons/mob/screen/cyborg.dmi'
	screen_loc = ui_borg_health