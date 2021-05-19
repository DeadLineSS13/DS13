/mob/living/carbon/alien
	hud_type = /datum/hud/larva

/datum/hud/larva/New(mob/living/carbon/alien/larva/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/obj/screen/using

	using = new /obj/screen/mov_intent/alien()
	using.icon_state = (owner.m_intent == MOVE_INTENT_DELIBERATE ? "walking" : "running")
	static_inventory += using
	move_intent = using

	healths = new /obj/screen/healths/alien()
	infodisplay += healths

	fire_icon = new /obj/screen/fire()
	fire_icon.icon = 'icons/mob/screen1_alien.dmi'
	infodisplay += fire_icon
