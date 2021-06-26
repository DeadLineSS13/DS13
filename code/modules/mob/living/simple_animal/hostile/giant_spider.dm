//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/giant_spider
	name = "Guard"
	desc = "Furry and brown, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/spidermeat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "pokes"
	attacktext = "bitten"
	stop_automated_movement_when_pulled = 0
	max_health = 120
	health = 120
	melee_damage_lower = 20
	melee_damage_upper = 25
	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	faction = "spiders"
	var/poison_per_bite = 5
	var/poison_type = /datum/reagent/toxin
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 6
	speed = 3
	max_gas = list(MATERIAL_PHORON = 1, "carbon_dioxide" = 5, "methyl_bromide" = 1)
	mob_size = MOB_LARGE
	pass_flags = PASS_FLAG_TABLE
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 4
	var/datum/action/innate/spider/lay_web/lay_web
	var/directive = "" //Message passed down to children, to relay the creator's orders
	var/friendly_to_human = FALSE
	poison_per_bite = 0
	var/is_busy = FALSE
	var/web_speed = 1

/mob/living/simple_animal/hostile/giant_spider/Initialize()
	. = ..()
	name = "[src.name] [rand(0,999)]"
	GLOB.spidermobs += src
	lay_web = new
	lay_web.Grant(src)

/mob/living/simple_animal/hostile/giant_spider/AttackingTarget()
	. = ..()
	if(.)
		inject_poison(target_mob)

/mob/living/simple_animal/hostile/giant_spider/proc/inject_poison(mob/living/living_target)
	if(poison_per_bite != 0 && living_target?.reagents)
		living_target.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_animal/hostile/giant_spider/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/observer = usr
		if(istype(observer))
			humanize_spider(observer)

/mob/living/simple_animal/hostile/giant_spider/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	if(target_mob)
		target_mob = null
	if(directive)
		to_chat(src, "<span class='notice'>Your mother left you a directive! Follow it at all costs.</span>")
		to_chat(src, "<span class='spider'><b>[directive]</b></span>")
	GLOB.spidermobs[src] = TRUE

/mob/living/simple_animal/hostile/giant_spider/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	humanize_spider(user)

/mob/living/simple_animal/hostile/giant_spider/proc/humanize_spider(mob/user)
	if(key || stat)//Someone is in it, it's dead, or the fun police are shutting it down
		return 0
	var/spider_ask = alert("Become a spider?", "Are you australian?", "Yes", "No")
	if(spider_ask == "No" || !src)
		return 1
	if(key)
		to_chat(user, "<span class='warning'>Someone else already took this spider!</span>")
		return 1
	key = user.key
	if(directive)
		log_game("[key_name(src)] took control of [name] with the objective: '[directive]'.")
	return 1

/mob/living/simple_animal/hostile/giant_spider/Destroy()
	GLOB.spidermobs -= src
	return ..()

/mob/living/simple_animal/hostile/giant_spider/nurse
	name = "Nurse"
	desc = "Furry and beige, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/spidereggs
	max_health = 80
	health = 80
	melee_damage_lower = 10
	melee_damage_upper = 15
	poison_per_bite = 3
	web_speed = 0.25

/mob/living/simple_animal/hostile/giant_spider/nurse/AttackingTarget()
	if(is_busy)
		return
	if(!istype(target_mob, /mob/living/simple_animal/hostile/giant_spider))
		return ..()
	var/mob/living/simple_animal/hostile/giant_spider/hurt_spider = target_mob
	if(hurt_spider == src)
		to_chat(src, "<span class='warning'>You don't have the dexerity to wrap your own wounds.</span>")
		return
	if(hurt_spider.health >= hurt_spider.max_health)
		to_chat(src, "<span class='warning'>You can't find any wounds to wrap up.</span>")
		return
	visible_message("<span class='notice'>[src] begins wrapping the wounds of [hurt_spider].</span>","<span class='notice'>You begin wrapping the wounds of [hurt_spider].</span>")
	is_busy = TRUE
	if(do_after(src, 20, target_mob = hurt_spider))
		hurt_spider.heal_overall_damage(20, 20)
		visible_message("<span class='notice'>[src] wraps the wounds of [hurt_spider].</span>","<span class='notice'>You wrap the wounds of [hurt_spider].</span>")
	is_busy = FALSE

//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/giant_spider/hunter
	name = "Hunter"
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	max_health = 100
	health = 100
	melee_damage_lower = 15
	melee_damage_upper = 20
	poison_per_bite = 10
	move_to_delay = 5

//vipers are the rare variant of the hunter, no IMMEDIATE damage but so much poison medical care will be needed fast.
/mob/living/simple_animal/hostile/giant_spider/viper
	name = "Viper"
	desc = "Furry and black, it makes you shudder to look at it. This one has effervescent purple eyes."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	max_health = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 5
	poison_per_bite = 12
	move_to_delay = 4
	speed = 5

//tarantulas are really tanky, regenerating (maybe), hulky monster but are also extremely slow, so.
/mob/living/simple_animal/hostile/giant_spider/tarantula
	name = "Tarantula"
	desc = "Furry and black, it makes you shudder to look at it. This one has abyssal red eyes."
	icon_state = "tarantula"
	icon_living = "tarantula"
	icon_dead = "tarantula_dead"
	max_health = 300 // woah nelly
	health = 300
	melee_damage_lower = 35
	melee_damage_upper = 40
	poison_per_bite = 0
	move_to_delay = 8
	speed = 1.5
	status_flags = NONE
	mob_size = MOB_LARGE

/mob/living/simple_animal/hostile/giant_spider/tarantula/movement_delay()
	var/turf/T = get_turf(src)
	if(locate(/obj/effect/spider/stickyweb) in T)
		speed = 5
	else
		speed = 1.5
	. = ..()

//midwives are the queen of the spiders, can send messages to all them and web faster. That rare round where you get a queen spider and turn your 'for honor' players into 'r6siege' players will be a fun one.
/mob/living/simple_animal/hostile/giant_spider/midwife
	name = "Midwife"
	desc = "Furry and black, it makes you shudder to look at it. This one has scintillating green eyes."
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	max_health = 80
	health = 80
	melee_damage_lower = 10
	melee_damage_upper = 15
	poison_per_bite = 3
	web_speed = 0.25
	var/atom/movable/cocoon_target
	var/fed = 0
	var/datum/action/innate/spider/lay_eggs/lay_eggs
	var/datum/action/innate/spider/lay_eggs/enriched/lay_eggs_enriched
	var/datum/action/innate/spider/set_directive/set_directive
	var/static/list/consumed_mobs = list()
	var/datum/action/innate/spider/comm/letmetalkpls

/mob/living/simple_animal/hostile/giant_spider/midwife/Initialize()
	. = ..()
	lay_eggs = new
	lay_eggs.Grant(src)
	lay_eggs_enriched = new
	lay_eggs_enriched.Grant(src)
	set_directive = new
	set_directive.Grant(src)
	letmetalkpls = new
	letmetalkpls.Grant(src)

/mob/living/simple_animal/hostile/giant_spider/New(var/location, var/atom/parent)
	get_light_and_color(parent)
	..()

/mob/living/simple_animal/hostile/giant_spider/midwife/proc/cocoon()
	if(stat == DEAD || !cocoon_target || cocoon_target.anchored)
		return
	if(cocoon_target == src)
		to_chat(src, "<span class='warning'>You can't wrap yourself!</span>")
		return
	if(istype(cocoon_target, /mob/living/simple_animal/hostile/giant_spider))
		to_chat(src, "<span class='warning'>You can't wrap other spiders!</span>")
		return
	if(!Adjacent(cocoon_target))
		to_chat(src, "<span class='warning'>You can't reach [cocoon_target]!</span>")
		return
	if(is_busy)
		to_chat(src, "<span class='warning'>You're already doing something else!</span>")
		return
	is_busy = TRUE
	visible_message("<span class='notice'>[src] begins to secrete a sticky substance around [cocoon_target].</span>","<span class='notice'>You begin wrapping [cocoon_target] into a cocoon.</span>")
	stop_automated_movement = TRUE
	if(do_after(src, 50, target = cocoon_target))
		if(is_busy)
			var/obj/effect/spider/cocoon/casing = new(cocoon_target.loc)
			if(isliving(cocoon_target))
				var/mob/living/living_target = cocoon_target
				if(ishuman(living_target) && (living_target.stat != DEAD || !consumed_mobs[living_target.tag])) //if they're not dead, you can consume them anyway
					consumed_mobs[living_target.tag] = TRUE
					fed++
					visible_message("<span class='danger'>[src] sticks a proboscis into [living_target] and sucks a viscous substance out.</span>","<span class='notice'>You suck the nutriment out of [living_target], feeding you enough to lay a cluster of eggs.</span>")
					living_target.death() //you just ate them, they're dead.
				else
					to_chat(src, "<span class='warning'>[living_target] cannot sate your hunger!</span>")
			cocoon_target.forceMove(casing)
			if(cocoon_target.density || ismob(cocoon_target))
				casing.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
	cocoon_target = null
	is_busy = FALSE
	stop_automated_movement = FALSE

/datum/action/innate/spider
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_ALIVE

/datum/action/innate/spider/lay_web
	name = "Spin a web to slow down potential prey."
	button_icon_state = "lay_web"

/datum/action/innate/spider/lay_web/Trigger()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider))
		return
	var/mob/living/simple_animal/hostile/giant_spider/S = owner

	if(!isturf(S.loc))
		return
	var/turf/T = get_turf(S)

	var/obj/effect/spider/stickyweb/W = locate() in T
	if(W)
		to_chat(S, "<span class='warning'>There's already a web here!</span>")
		return

	if(!S.is_busy)
		S.is_busy = TRUE
		S.visible_message("<span class='notice'>[S] begins to secrete a sticky substance.</span>","<span class='notice'>You begin to lay a web.</span>")
		S.stop_automated_movement = TRUE
		if(do_after(S, 40 * S.web_speed, target = T))
			if(S.is_busy && S.loc == T)
				new /obj/effect/spider/stickyweb(T)
		S.is_busy = FALSE
		S.stop_automated_movement = FALSE
	else
		to_chat(S, "<span class='warning'>You're already doing something else!</span>")

/mob/living/simple_animal/hostile/giant_spider/midwife/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to feast upon and objects for safe keeping."

	if(stat == DEAD)
		return 0
	if(!cocoon_target)
		var/list/choices = list()
		for(var/mob/living/L in view(1,src))
			if(L == src || L.anchored)
				continue
			if(istype(L, /mob/living/simple_animal/hostile/giant_spider))
				continue
			if(Adjacent(L))
				choices += L
		for(var/obj/O in src.loc)
			if(O.anchored)
				continue
			if(Adjacent(O))
				choices += O
		var/temp_input = input(src,"What do you wish to cocoon?") in null|choices
		if(temp_input && !cocoon_target)
			cocoon_target = temp_input

	cocoon(cocoon_target)

/datum/action/innate/spider/lay_eggs
	name = "Lay a cluster of eggs, which will soon grow into a normal spider."
	button_icon_state = "lay_eggs"
	var/enriched = FALSE

/datum/action/innate/spider/lay_eggs/IsAvailable()
	. = ..()
	if(!.)
		return
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return FALSE
	return TRUE

/datum/action/innate/spider/lay_eggs/Trigger()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return
	var/mob/living/simple_animal/hostile/giant_spider/midwife/spider = owner

	var/obj/effect/spider/eggcluster/eggs = locate() in get_turf(spider)
	if(eggs)
		to_chat(spider, "<span class='warning'>There is already a cluster of eggs here!</span>")
	else if(enriched && !spider.fed)
		to_chat(spider, "<span class='warning'>You are too hungry to do this!</span>")
	else if(!spider.is_busy)
		spider.is_busy = TRUE
		spider.visible_message("<span class='notice'>[spider] begins to lay a cluster of eggs.</span>","<span class='notice'>You begin to lay a cluster of eggs.</span>")
		spider.stop_automated_movement = TRUE
		if(do_after(spider, 100, target = get_turf(spider)))
			if(spider.is_busy)
				eggs = locate() in get_turf(spider)
				if(!eggs || !isturf(spider.loc))
					var/egg_choice = enriched ? /obj/effect/spider/eggcluster/enriched : /obj/effect/spider/eggcluster
					var/obj/effect/spider/eggcluster/new_eggs = new egg_choice(get_turf(spider))
					new_eggs.directive = spider.directive
					new_eggs.faction = spider.faction
					if(enriched)
						spider.fed--
		spider.is_busy = FALSE
		spider.stop_automated_movement = FALSE

/datum/action/innate/spider/lay_eggs/enriched
	name = "Lay Enriched Eggs"
	button_icon_state = "lay_enriched_eggs"
	enriched = TRUE

/datum/action/innate/spider/set_directive
	name = "Set a directive for your children to follow."
	button_icon_state = "directive"

/datum/action/innate/spider/set_directive/IsAvailable()
	if(..())
		if(istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
			return TRUE

/datum/action/innate/spider/set_directive/Trigger()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return
	var/mob/living/simple_animal/hostile/giant_spider/midwife/S = owner
	S.directive = input(S, "Enter the new directive", "Create directive", "")
	to_chat(S, "<span class='notice'>New directive set.</span>")
	to_chat(S, "<span class='spider'><b>[S.directive]</b></span>")

/datum/action/innate/spider/comm
	name = "Send a command to all living spiders."
	button_icon_state = "command"

/datum/action/innate/spider/comm/IsAvailable()
	if(istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return TRUE
	return FALSE

/datum/action/innate/spider/comm/Trigger()
	var/input = input(usr, "Input a message for your legions.", "Command", "")
	if(QDELETED(src) || !input || !IsAvailable())
		return FALSE
	spider_command(usr, input)
	return TRUE

/datum/action/innate/spider/comm/proc/spider_command(mob/living/user, spider_command)
	if(!spider_command)
		return
	var/my_message
	my_message = "<FONT size = 3><b>COMMAND FROM SPIDER QUEEN:</b> [spider_command]</FONT>"
	for(var/mob/living/simple_animal/hostile/giant_spider/M in GLOB.spidermobs)
		to_chat(M, my_message)
	for(var/mob/observer/O in GLOB.dead_mob_list)
		to_chat(O, my_message)
