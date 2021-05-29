/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/mob
	var/hud_type = null
	var/datum/hud/hud_used = null

/mob/proc/InitializeHud()

	if(hud_used)
		qdel(hud_used)
	if(hud_type)
		hud_used = new hud_type(src)
	else
		hud_used = new /datum/hud

/datum/hud
	var/mob/mymob

	var/hud_version = HUD_STYLE_STANDARD	//the hud version used (standard, reduced, none)
	var/hud_shown = TRUE		//Used for the HUD toggle (F12)
	var/inventory_shown = TRUE	//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/move_intent

	var/obj/screen/nutrition_icon

	var/obj/screen/zone_sel
	var/obj/screen/pull_icon
	var/obj/screen/throw_icon
	var/obj/screen/rest_icon
	var/obj/screen/oxygen_icon
	var/obj/screen/pressure_icon
	var/obj/screen/toxin_icon
	var/obj/screen/internals
	var/obj/screen/healths
	var/obj/screen/fire_icon
	var/obj/screen/bodytemp_icon
	var/obj/screen/pullin
	var/obj/screen/purged
	var/obj/screen/i_select
	var/obj/screen/m_select

	var/obj/screen/gun/item/item_use_icon
	var/obj/screen/gun/radio/radio_use_icon
	var/obj/screen/gun/move/gun_move_icon
	var/obj/screen/gun/run/gun_run_icon
	var/obj/screen/gun/mode/gun_setting_icon

	var/list/static_inventory = list() //the screen objects which are static
	var/list/toggleable_inventory = list() //the screen objects which can be hidden
	var/list/obj/screen/hotkeybuttons = list() //the buttons that can be used via hotkeys
	var/list/infodisplay = list() //the screen objects that display mob info (health, etc...)

	var/obj/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

	var/list/obj/screen/plane_master/plane_masters = list() // see "appearance_flags" in the ref, assoc list of "[plane]" = object

/datum/hud/New(mob/owner)
	mymob = owner
	hide_actions_toggle = new

	for(var/mytype in subtypesof(/obj/screen/plane_master))
		var/obj/screen/plane_master/instance = new mytype()
		plane_masters["[instance.plane]"] = instance
		instance.backdrop(mymob)

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null
	QDEL_LIST(static_inventory)
	QDEL_LIST(toggleable_inventory)
	QDEL_LIST(hotkeybuttons)
	QDEL_LIST(infodisplay)

	qdel(hide_actions_toggle)
	hide_actions_toggle = null

	lingchemdisplay = null
	r_hand_hud_object = null
	l_hand_hud_object = null
	action_intent = null
	move_intent = null

	zone_sel = null
	pull_icon = null
	throw_icon = null
	oxygen_icon = null
	pressure_icon = null
	toxin_icon = null
	internals = null
	healths = null
	fire_icon = null
	bodytemp_icon = null

	QDEL_LIST_ASSOC_VAL(plane_masters)

	mymob = null

	return ..()

/mob/proc/create_mob_hud()
	if(!client || hud_used)
		return
	var/ui_style = ui_style2icon(client.prefs.UI_style)
	var/ui_color = client.prefs.UI_style_color
	var/ui_alpha = client.prefs.UI_style_alpha
	hud_used = new hud_type(src, ui_style, ui_color, ui_alpha)
	update_sight()
