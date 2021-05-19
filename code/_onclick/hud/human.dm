/mob/living/carbon/human
	hud_type = /datum/hud/human

/datum/hud/human/Destroy()
	.=..()

/datum/hud/human/New(mob/living/carbon/human/owner, ui_style='icons/mob/screen1_White.dmi', ui_color = "#ffffff", ui_alpha = 230)
	. = ..()
	owner.overlay_fullscreen("see_through_darkness", /obj/screen/fullscreen/see_through_darkness)

	var/datum/hud_data/hud_data
	if(!istype(owner))
		hud_data = new()
	else
		hud_data = owner.species.hud

	if(hud_data.icon)
		ui_style = hud_data.icon

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	// Draw the various inventory equipment slots.
	var/has_hidden_gear
	for(var/gear_slot in hud_data.gear)

		inv_box = new /obj/screen/inventory()
		inv_box.icon = ui_style
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha

		var/list/slot_data =  hud_data.gear[gear_slot]
		inv_box.name =        gear_slot
		inv_box.screen_loc =  slot_data["loc"]
		inv_box.slot_id =     slot_data["slot"]
		inv_box.icon_state =  slot_data["state"]

		if(slot_data["toggle"])
			toggleable_inventory += inv_box
			has_hidden_gear = 1
		else
			static_inventory += inv_box

	if(has_hidden_gear)
		using = new /obj/screen/toggle_inv()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

	// Draw the attack intent dialogue.
	if(hud_data.has_a_intent)

		using = new /obj/screen/act_intent/corner()
		using.icon_state = owner.a_intent
		using.alpha = ui_alpha
		static_inventory += using
		action_intent = using



	if(hud_data.has_m_intent)
		using = new /obj/screen/mov_intent()
		using.icon = ui_style
		using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using
		move_intent = using

	if(hud_data.has_drop)
		using = new /obj/screen/drop()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		hotkeybuttons += using

	if(hud_data.has_hands)

		using = new /obj/screen/human/equip
		using.icon = ui_style
		using.plane = ABOVE_HUD_PLANE
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

		inv_box = new /obj/screen/inventory/hand/right()
		inv_box.icon = ui_style
		if(owner && !owner.hand)	//This being 0 or null means the right hand is in use
			inv_box.add_overlay("hand_active")
		inv_box.slot_id = SLOT_R_HAND
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha
		r_hand_hud_object = inv_box
		static_inventory += inv_box

		inv_box = new /obj/screen/inventory/hand()
		inv_box.setDir(EAST)
		inv_box.icon = ui_style
		if(owner?.hand)	//This being 1 means the left hand is in use
			inv_box.add_overlay("hand_active")
		inv_box.slot_id = SLOT_L_HAND
		inv_box.color = ui_color
		inv_box.alpha = ui_alpha
		l_hand_hud_object = inv_box
		static_inventory += inv_box

		using = new /obj/screen/swap_hand/human()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

		using = new /obj/screen/swap_hand/right()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		static_inventory += using

	if(hud_data.has_resist)
		using = new /obj/screen/resist()
		using.icon = ui_style
		using.color = ui_color
		using.alpha = ui_alpha
		hotkeybuttons += using

	if(hud_data.has_throw)
		throw_icon = new /obj/screen/throw_catch()
		throw_icon.icon = ui_style
		throw_icon.color = ui_color
		throw_icon.alpha = ui_alpha
		hotkeybuttons += throw_icon

		pull_icon = new /obj/screen/pull()
		pull_icon.icon = ui_style
		pull_icon.update_icon(owner)
		hotkeybuttons += pull_icon


	if(hud_data.has_internals)
		internals = new /obj/screen/internals()
		infodisplay += internals

	if(hud_data.has_warnings)
		oxygen_icon = new /obj/screen/oxygen()
		infodisplay += oxygen_icon

		toxin_icon = new /obj/screen()
		toxin_icon.icon_state = "tox0"
		toxin_icon.name = "toxin"
		toxin_icon.screen_loc = ui_toxin
		infodisplay += toxin_icon

		fire_icon = new /obj/screen/fire()
		infodisplay += fire_icon

		healths = new /obj/screen/healths()
		infodisplay += healths


	if(hud_data.has_pressure)
		pressure_icon = new /obj/screen()
		pressure_icon.icon_state = "pressure0"
		pressure_icon.name = "pressure"
		pressure_icon.screen_loc = ui_pressure
		infodisplay += pressure_icon

	if(hud_data.has_bodytemp)
		bodytemp_icon = new /obj/screen/bodytemp()
		infodisplay += bodytemp_icon


	if(hud_data.has_nutrition)
		nutrition_icon = new /obj/screen()
		nutrition_icon.icon_state = "nutrition0"
		nutrition_icon.name = "nutrition"
		nutrition_icon.screen_loc = ui_nutrition
		infodisplay += nutrition_icon

	rest_icon = new /obj/screen/rest()
	rest_icon.icon = ui_style
	rest_icon.color = ui_color
	rest_icon.alpha = ui_alpha
	rest_icon.update_icon(owner)
	static_inventory += rest_icon

	zone_sel = new /obj/screen/zone_sel()
	zone_sel.icon = ui_style
	zone_sel.color = ui_color
	zone_sel.alpha = ui_alpha
	zone_sel.update_icon(owner)
	static_inventory += zone_sel

/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = "This disables or enables the user interface buttons which can be used with hotkeys."

	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 0
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = 1
