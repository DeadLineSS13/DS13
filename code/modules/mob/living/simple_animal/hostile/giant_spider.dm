#define SPIDER_IDLE 0
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/giant_spider
	name = "giant spider"
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
	stop_automated_movement_when_pulled = 0
	max_health = 200
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 20
	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	var/poison_per_bite = 5
	var/poison_type = /datum/reagent/toxin
	faction = "spiders"
	var/busy = SPIDER_IDLE
	pass_flags = PASS_FLAG_TABLE
	move_to_delay = 6
	speed = 3
	max_gas = list(MATERIAL_PHORON = 1, "carbon_dioxide" = 5, "methyl_bromide" = 1)
	mob_size = MOB_LARGE
	pass_flags = PASS_FLAG_TABLE
	see_invisible = SEE_INVISIBLE_MINIMUM
	see_in_dark = 4
	var/playable_spider = FALSE
	var/datum/action/innate/spider/lay_web/lay_web
	var/directive = "" //Message passed down to children, to relay the creator's orders

/mob/living/simple_animal/hostile/giant_spider/nurse/Initialize()
	. = ..()
	lay_web = new
	lay_web.Grant(src)

/mob/living/simple_animal/hostile/giant_spider/Topic(href, href_list)
	if(href_list["activate"])
		var/mob/observer = usr
		if(istype(observer) && playable_spider)
			humanize_spider(observer)

/mob/living/simple_animal/hostile/giant_spider/Login()
	..()
	if(directive)
		to_chat(src, "<span class='notice'>Your mother left you a directive! Follow it at all costs.</span>")
		to_chat(src, "<span class='spider'><b>[directive]</b></span>")

/mob/living/simple_animal/hostile/giant_spider/attack_ghost(mob/user)
	if(!humanize_spider(user))
		return ..()

/mob/living/simple_animal/hostile/giant_spider/proc/humanize_spider(mob/user)
	if(ckey || !playable_spider)//Someone is in it or the fun police are shutting it down
		return 0
	var/spider_ask = alert("Become a spider?", "Are you australian?", "Yes", "No")
	if(spider_ask == "No" || !src)
		return 1
	if(key)
		to_chat(user, "<span class='notice'>Someone else already took this spider.</span>")
		return 1
	key = user.key
	return 1

//nursemaids - these create webs and eggs
/mob/living/simple_animal/hostile/giant_spider/nurse
	desc = "Furry and beige, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/spidereggs
	max_health = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 10
	var/atom/movable/cocoon_target
	poison_type = /datum/reagent/soporific
	var/fed = 0
	var/static/list/consumed_mobs = list() //the tags of mobs that have been consumed by nurse spiders to lay eggs
//	var/datum/action/innate/spider/wrap/wrap
	var/datum/action/innate/spider/lay_eggs/lay_eggs
	var/datum/action/innate/spider/set_directive/set_directive

/mob/living/simple_animal/hostile/giant_spider/nurse/Initialize()
	. = ..()
//	wrap = new
//	wrap.Grant(src)
	lay_eggs = new
	lay_eggs.Grant(src)
	set_directive = new
	set_directive.Grant(src)

//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	max_health = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 5
	move_to_delay = 4

//vipers are the rare variant of the hunter, no IMMEDIATE damage but so much poison medical care will be needed fast.
/mob/living/simple_animal/hostile/giant_spider/hunter/viper
	name = "viper"
	desc = "Furry and black, it makes you shudder to look at it. This one has effervescent purple eyes."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	max_health = 40
	health = 40
	melee_damage_lower = 1
	melee_damage_upper = 1
	poison_per_bite = 12
	move_to_delay = 4
	poison_type = "venom" //all in venom, glass cannon. you bite 5 times and they are DEFINITELY dead, but 40 health and you are extremely obvious. Ambush, maybe?
	speed = 1

//tarantulas are really tanky, regenerating (maybe), hulky monster but are also extremely slow, so.
/mob/living/simple_animal/hostile/giant_spider/tarantula
	name = "tarantula"
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
	speed = 7
	status_flags = NONE
	mob_size = MOB_LARGE

/mob/living/simple_animal/hostile/giant_spider/tarantula/movement_delay()
	var/turf/T = get_turf(src)
	if(locate(/obj/effect/spider/stickyweb) in T)
		speed = 2
	else
		speed = 7
	. = ..()

//midwives are the queen of the spiders, can send messages to all them and web faster. That rare round where you get a queen spider and turn your 'for honor' players into 'r6siege' players will be a fun one.
/mob/living/simple_animal/hostile/giant_spider/nurse/midwife
	name = "midwife"
	desc = "Furry and black, it makes you shudder to look at it. This one has scintillating green eyes."
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	max_health = 40
	health = 40
	var/datum/action/innate/spider/comm/letmetalkpls

/mob/living/simple_animal/hostile/giant_spider/nurse/midwife/Initialize()
	. = ..()
	letmetalkpls = new
	letmetalkpls.Grant(src)

/mob/living/simple_animal/hostile/giant_spider/New(var/location, var/atom/parent)
	get_light_and_color(parent)
	..()

/mob/living/simple_animal/hostile/giant_spider/AttackingTarget()
	. = ..()
	if(isliving(.))
		var/mob/living/L = .
		if(L.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)

/mob/living/simple_animal/hostile/giant_spider/nurse/AttackingTarget()
	. = ..()
	if(ishuman(.))
		var/mob/living/carbon/human/H = .
		if(prob(poison_per_bite))
			var/obj/item/organ/external/O = pick(H.organs)
			if(!BP_IS_ROBOTIC(O))
				var/eggs = new /obj/effect/spider/eggcluster(O, src)
				O.implants += eggs

/mob/living/simple_animal/hostile/giant_spider/Life()
	..()
	if(!stat && !ckey)
		if(stance == HOSTILE_STANCE_IDLE)
			//1% chance to skitter madly away
			if(!busy && prob(1))
				/*var/list/move_targets = list()
				for(var/turf/T in orange(20, src))
					move_targets.Add(T)*/
				stop_automated_movement = 1
				walk_to(src, pick(orange(20, src)), 1, move_to_delay)
				spawn(50)
					stop_automated_movement = FALSE
					walk(src,0)

/mob/living/simple_animal/hostile/giant_spider/nurse/proc/GiveUp(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = SPIDER_IDLE
			stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/giant_spider/nurse/Life()
	..()
	if(!stat && !ckey)
		if(stance == HOSTILE_STANCE_IDLE)
			var/list/can_see = view(src, 10)
			//30% chance to stop wandering and do something
			if(!busy && prob(30))
				//first, check for potential food nearby to cocoon
				for(var/mob/living/C in can_see)
					if(C.stat)
						cocoon_target = C
						busy = MOVING_TO_TARGET
						walk_to(src, C, 1, move_to_delay)
						//give up if we can't reach them after 10 seconds
						GiveUp(C)
						return

				//second, spin a sticky spiderweb on this tile
				var/obj/effect/spider/stickyweb/W = locate() in get_turf(src)
				if(!W)
					lay_web.Trigger()
				else
					//third, lay an egg cluster there
					if(fed)
						lay_eggs.Trigger()
					else
						//fourthly, cocoon any nearby items so those pesky pinkskins can't use them
						for(var/obj/O in can_see)

							if(O.anchored)
								continue

							if(istype(O, /obj/item) || istype(O, /obj/structure) || istype(O, /obj/machinery))
								cocoon_target = O
								busy = MOVING_TO_TARGET
								stop_automated_movement = 1
								walk_to(src, O, 1, move_to_delay)
								//give up if we can't reach them after 10 seconds
								GiveUp(O)

			else if(busy == MOVING_TO_TARGET && cocoon_target)
				if(get_dist(src, cocoon_target) <= 1)
					Wrap()

		else
			busy = SPIDER_IDLE
			stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/giant_spider/Login()
	. = ..()
	GLOB.spidermobs[src] = TRUE

/mob/living/simple_animal/hostile/giant_spider/Destroy()
	GLOB.spidermobs -= src
	return ..()

/datum/action/innate/spider
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_ALIVE

/datum/action/innate/spider/lay_web
	name = "Spin a web to slow down potential prey."
	button_icon_state = "lay_web"

/datum/action/innate/spider/lay_web/Trigger()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/giant_spider/nurse/S = owner

	if(!isturf(S.loc))
		return
	var/turf/T = get_turf(S)

	var/obj/effect/spider/stickyweb/W = locate() in T
	if(W)
		to_chat(S, "<span class='warning'>There's already a web here!</span>")
		return

	if(S.busy != SPINNING_WEB)
		S.busy = SPINNING_WEB
		S.visible_message("<span class='notice'>[S] begins to secrete a sticky substance.</span>","<span class='notice'>You begin to lay a web.</span>")
		S.stop_automated_movement = TRUE
		if(do_after(S, 40, target = T))
			if(S.busy == SPINNING_WEB && S.loc == T)
				new /obj/effect/spider/stickyweb(T)
		S.busy = SPIDER_IDLE
		S.stop_automated_movement = FALSE
	else
		to_chat(S, "<span class='warning'>You're already spinning a web!</span>")

///datum/action/innate/spider/wrap
//	name = "Wrap something or someone in a cocoon. If it's a living being, you'll also consume them, allowing you to lay eggs."
//	button_icon_state = "wrap_0"



/datum/action/innate/spider/lay_eggs
	name = "Lay a cluster of eggs, which will soon grow into more spiders. You must wrap a living being to do this."
	button_icon_state = "lay_eggs"

/datum/action/innate/spider/lay_eggs/IsAvailable()
	if(..())
		if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/nurse))
			return 0
		var/mob/living/simple_animal/hostile/giant_spider/nurse/S = owner
		if(S.fed)
			return 1
		return 0

/datum/action/innate/spider/lay_eggs/Trigger()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/giant_spider/nurse/S = owner

	var/obj/effect/spider/eggcluster/E = locate() in get_turf(S)
	if(E)
		to_chat(S, "<span class='warning'>There is already a cluster of eggs here!</span>")
	else if(!S.fed)
		to_chat(S, "<span class='warning'>You are too hungry to do this!</span>")
	else if(S.busy != LAYING_EGGS)
		S.busy = LAYING_EGGS
		S.visible_message("<span class='notice'>[S] begins to lay a cluster of eggs.</span>","<span class='notice'>You begin to lay a cluster of eggs.</span>")
		S.stop_automated_movement = TRUE
		if(do_after(S, 50, target = get_turf(S)))
			if(S.busy == LAYING_EGGS)
				E = locate() in get_turf(S)
				if(!E || !isturf(S.loc))
					var/obj/effect/spider/eggcluster/C = new /obj/effect/spider/eggcluster(get_turf(S))
					if(S.ckey)
						C.player_spiders = TRUE
					C.directive = S.directive
					C.poison_type = S.poison_type
					C.poison_per_bite = S.poison_per_bite
					C.faction = S.faction
					S.fed--
		S.busy = SPIDER_IDLE
		S.stop_automated_movement = FALSE

/datum/action/innate/spider/set_directive
	name = "Set a directive for your children to follow."
	button_icon_state = "directive"

/datum/action/innate/spider/set_directive/Trigger()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/giant_spider/nurse/S = owner
	S.directive = input(S, "Enter the new directive", "Create directive", "")
	to_chat(S, S.directive)

/datum/action/innate/spider/comm
	name = "Send a command to all living spiders."
	button_icon_state = "command"

/datum/action/innate/spider/comm/IsAvailable()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/nurse/midwife))
		return FALSE
	return TRUE

/datum/action/innate/spider/comm/Trigger()
	var/input = input(usr, "Input a message for your legions.", "Command", "")
	if(QDELETED(src) || !input || !IsAvailable())
		return FALSE
	spider_command(usr, input)
	return TRUE

/datum/action/innate/spider/comm/proc/spider_command(mob/living/user, message)
	if(!message)
		return
	var/my_message
	my_message = "<FONT size = 3><b>COMMAND FROM SPIDER QUEEN:</b> [message]</FONT>"
	for(var/mob/living/simple_animal/hostile/giant_spider/M in GLOB.spidermobs)
		to_chat(M, my_message)

#undef SPIDER_IDLE
#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
