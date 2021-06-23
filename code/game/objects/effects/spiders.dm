//generic procs copied from obj/effect/alien
/obj/effect/spider
	name = "web"
	desc = "It's stringy and sticky."
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	density = FALSE
	health = 15

//similar to weeds, but only barfed out by nurses manually
/obj/effect/spider/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
		if(3)
			if (prob(5))
				qdel(src)

/obj/effect/spider/attackby(var/obj/item/weapon/W, var/mob/user)
	user.set_click_cooldown(DEFAULT_ATTACK_COOLDOWN)

	if(W.attack_verb.len)
		visible_message("<span class='danger'>[user] has [pick(W.attack_verb)] \the [src] with \the [W]!</span>")
	else
		visible_message("<span class='danger'>[user] has attacked \the [src] with \the [W]!</span>")

	var/damage = W.force / 4


	health -= damage
	healthcheck()

/obj/effect/spider/bullet_act(var/obj/item/projectile/Proj)
	..()
	health -= Proj.get_structure_damage()
	healthcheck()

/obj/effect/spider/proc/healthcheck()
	if(health <= 0)
		qdel(src)

/obj/effect/spider/fire_act(var/datum/gas_mixture/air, var/exposed_temperature, var/exposed_volume, var/multiplier = 1)
	if(exposed_temperature > 300 + T0C)
		health -= 5
		healthcheck()

/obj/effect/spider/stickyweb
	icon_state = "stickyweb1"
	New()
		if(prob(50))
			icon_state = "stickyweb2"

/obj/effect/spider/stickyweb/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/hostile/giant_spider))
		return 1
	else if(isliving(mover))
		if(prob(50))
			to_chat(mover, "<span class='warning'>You get stuck in \the [src] for a moment.</span>")
			return 0
	else if(istype(mover, /obj/item/projectile))
		return prob(30)
	return 1

/obj/effect/spider/eggcluster
	name = "egg cluster"
	desc = "They seem to pulse slightly with an inner life."
	icon_state = "eggs"
	var/amount_grown = 0
	var/player_spiders = 0
	var/poison_type = /datum/reagent/toxin
	var/poison_per_bite = 5
	var/list/faction = list("spiders")
	var/directive = "" //Message from the mother

/obj/effect/spider/eggcluster/Initialize()
		. = ..()
		pixel_x = rand(3,-3)
		pixel_y = rand(3,-3)
		START_PROCESSING(SSobj, src)

/obj/effect/spider/eggcluster/New(var/location, var/atom/parent)
	get_light_and_color(parent)
	..()

/obj/effect/spider/eggcluster/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(istype(loc, /obj/item/organ/external))
		var/obj/item/organ/external/O = loc
		O.implants -= src
	. = ..()

/obj/effect/spider/eggcluster/Process()
	amount_grown += rand(0,2)
	if(amount_grown >= 100)
		var/num = rand(3,12)
		for(var/i=0, i<num, i++)
			var/obj/effect/spider/spiderling/S = new /obj/effect/spider/spiderling(src.loc)
			S.poison_type = poison_type
			S.poison_per_bite = poison_per_bite
			S.faction = faction.Copy()
			S.directive = directive
			if(player_spiders)
				S.player_spiders = 1
		qdel(src)

/obj/effect/spider/spiderling
	name = "spiderling"
	desc = "It never stays still for long."
	icon_state = "spiderling"
	anchored = FALSE
	layer = BELOW_OBJ_LAYER
	health = 3
	var/mob/living/simple_animal/hostile/giant_spider/greater_form
	var/last_itch = 0
	var/amount_grown = 0
	var/grow_as = null
	var/obj/machinery/atmospherics/unary/vent_pump/entry_vent
	var/travelling_in_vent = 0
	var/dormant = FALSE    // If dormant, does not add the spiderling to the process list unless it's also growing
	var/growth_chance = 50 // % chance of beginning growth, and eventually become a beautiful death machine
	var/player_spiders = 0
	var/poison_type = /datum/reagent/toxin
	var/poison_per_bite = 5
	var/list/faction = list("spiders")
	var/shift_range = 6
	var/directive = "" //Message from the mother

/obj/effect/spider/spiderling/Initialize(var/mapload, var/atom/parent)
	greater_form = pick(typesof(/mob/living/simple_animal/hostile/giant_spider))
	icon_state = initial(greater_form.icon_state)
	pixel_x = rand(-shift_range, shift_range)
	pixel_y = rand(-shift_range, shift_range)

	if(prob(growth_chance))
		amount_grown = 1
		dormant = FALSE

	if(dormant)
		GLOB.moved_event.register(src, src, /obj/effect/spider/spiderling/proc/disturbed)
	else
		START_PROCESSING(SSobj, src)

	get_light_and_color(parent)
	. = ..()

/obj/effect/spider/spiderling/mundane
	growth_chance = 0 // Just a simple, non-mutant spider

/obj/effect/spider/spiderling/mundane/dormant
	dormant = TRUE    // It lies in wait, hoping you will walk face first into its web

/obj/effect/spider/spiderling/Destroy()
	if(dormant)
		GLOB.moved_event.unregister(src, src, /obj/effect/spider/spiderling/proc/disturbed)
	STOP_PROCESSING(SSobj, src)
	walk(src, 0) // Because we might have called walk_to, we must stop the walk loop or BYOND keeps an internal reference to us forever.
	. = ..()

/obj/effect/spider/spiderling/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if(health > 0)
		disturbed()

/obj/effect/spider/spiderling/Crossed(var/mob/living/L)
	if(dormant && istype(L) && L.mob_size > MOB_TINY)
		disturbed()

/obj/effect/spider/spiderling/proc/disturbed()
	if(!dormant)
		return
	dormant = FALSE

	GLOB.moved_event.unregister(src, src, /obj/effect/spider/spiderling/proc/disturbed)
	START_PROCESSING(SSobj, src)

/obj/effect/spider/spiderling/hunter
	grow_as = /mob/living/simple_animal/hostile/giant_spider/hunter

/obj/effect/spider/spiderling/nurse
	grow_as = /mob/living/simple_animal/hostile/giant_spider/nurse

/obj/effect/spider/spiderling/midwife
	grow_as = /mob/living/simple_animal/hostile/giant_spider/nurse/midwife

/obj/effect/spider/spiderling/viper
	grow_as = /mob/living/simple_animal/hostile/giant_spider/hunter/viper

/obj/effect/spider/spiderling/tarantula
	grow_as = /mob/living/simple_animal/hostile/giant_spider/tarantula

/obj/effect/spider/spiderling/Bump(atom/user)
	if(istype(user, /obj/structure/table))
		src.loc = user.loc
	else
		..()

/obj/effect/spider/spiderling/proc/die()
	visible_message("<span class='alert'>[src] dies!</span>")
	new /obj/effect/decal/cleanable/spiderling_remains(loc)
	qdel(src)

/obj/effect/spider/spiderling/healthcheck()
	if(health <= 0)
		die()

/obj/effect/spider/spiderling/Process()

	if(loc)
		var/datum/gas_mixture/environment = loc.return_air()
		if(environment && environment.gas["methyl_bromide"] > 0)
			die()
			return

	if(travelling_in_vent)
		if(istype(src.loc, /turf))
			travelling_in_vent = 0
			entry_vent = null
	else if(entry_vent)
		if(get_dist(src, entry_vent) <= 1)
			if(entry_vent.network && entry_vent.network.normal_members.len)
				var/list/vents = list()
				for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in entry_vent.network.normal_members)
					vents.Add(temp_vent)
				if(!vents.len)
					entry_vent = null
					return
				var/obj/machinery/atmospherics/unary/vent_pump/exit_vent = pick(vents)
				/*if(prob(50))
					src.visible_message("<B>[src] scrambles into the ventillation ducts!</B>")*/

				spawn(rand(20,60))
					loc = exit_vent
					var/travel_time = round(get_dist(loc, exit_vent.loc) / 2)
					spawn(travel_time)

						if(!exit_vent || exit_vent.welded)
							loc = entry_vent
							entry_vent = null
							return

						if(prob(50))
							src.visible_message("<span class='notice'>You hear something squeezing through the ventilation ducts.</span>",2)
						sleep(travel_time)

						if(!exit_vent || exit_vent.welded)
							loc = entry_vent
							entry_vent = null
							return
						loc = exit_vent.loc
						entry_vent = null
						var/area/new_area = get_area(loc)
						if(new_area)
							new_area.Entered(src)
			else
				entry_vent = null
	//=================

	if(isturf(loc))
		if(prob(25))
			var/list/nearby = trange(5, src) - loc
			if(nearby.len)
				var/target_atom = pick(nearby)
				walk_to(src, target_atom, 5)
				if(prob(25))
					src.visible_message("<span class='notice'>\The [src] skitters[pick(" away"," around","")].</span>")
					// Reduces the risk of spiderlings hanging out at the extreme ranges of the shift range.
					var/min_x = pixel_x <= -shift_range ? 0 : -2
					var/max_x = pixel_x >=  shift_range ? 0 :  2
					var/min_y = pixel_y <= -shift_range ? 0 : -2
					var/max_y = pixel_y >=  shift_range ? 0 :  2

					pixel_x = Clamp(pixel_x + rand(min_x, max_x), -shift_range, shift_range)
					pixel_y = Clamp(pixel_y + rand(min_y, max_y), -shift_range, shift_range)
		else if(prob(5))
			//vent crawl!
			for(var/obj/machinery/atmospherics/unary/vent_pump/v in view(7,src))
				if(!v.welded)
					entry_vent = v
					walk_to(src, entry_vent, 5)
					break

		if(amount_grown >= 100)
			if(!grow_as)
				grow_as = pick(/mob/living/simple_animal/hostile/giant_spider, /mob/living/simple_animal/hostile/giant_spider/hunter, /mob/living/simple_animal/hostile/giant_spider/nurse)
				if(prob(3))
					grow_as = pick(/mob/living/simple_animal/hostile/giant_spider/tarantula, /mob/living/simple_animal/hostile/giant_spider/hunter/viper, /mob/living/simple_animal/hostile/giant_spider/nurse/midwife)
				else
					grow_as = pick(/mob/living/simple_animal/hostile/giant_spider, /mob/living/simple_animal/hostile/giant_spider/hunter, /mob/living/simple_animal/hostile/giant_spider/nurse)
			var/mob/living/simple_animal/hostile/giant_spider/S = new grow_as(src.loc)
			S.poison_per_bite = poison_per_bite
			S.poison_type = poison_type
			S.faction = faction.Copy()
			S.directive = directive
			if(player_spiders)
				var/list/candidates = get_antags(ANTAG_SPIDER)
				var/client/C = null
				S.playable_spider = TRUE

				if(candidates.len)
					C = pick(candidates)
					S.key = C.key
			qdel(src)

	else if(isorgan(loc))
		if(!amount_grown) amount_grown = 1
		var/obj/item/organ/external/O = loc
		if(!O.owner || O.owner.stat == DEAD || amount_grown > 80)
			amount_grown = 20 //reset amount_grown so that people have some time to react to spiderlings before they grow big
			O.implants -= src
			src.loc = O.owner ? O.owner.loc : O.loc
			src.visible_message("<span class='warning'>\A [src] emerges from inside [O.owner ? "[O.owner]'s [O.name]" : "\the [O]"]!</span>")
			if(O.owner)
				O.owner.apply_damage(1, BRUTE, O.organ_tag)
		else if(prob(1))
			O.owner.apply_damage(1, TOX, O.organ_tag)
			if(world.time > last_itch + 30 SECONDS)
				last_itch = world.time
				to_chat(O.owner, "<span class='notice'>Your [O.name] itches...</span>")
	else if(prob(1))
		src.visible_message("<span class='notice'>\The [src] skitters.</span>")

	if(amount_grown > 0)
		amount_grown += rand(0,2)

/obj/effect/decal/cleanable/spiderling_remains
	name = "spiderling remains"
	desc = "Green squishy mess."
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenshatter"
	anchored = TRUE

	layer = BLOOD_LAYER

/obj/effect/spider/cocoon
	name = "cocoon"
	desc = "Something wrapped in silky spider web."
	icon_state = "cocoon1"
	health = 60

	New()
		icon_state = pick("cocoon1","cocoon2","cocoon3")

/obj/effect/spider/cocoon/Destroy()
	var/turf/T = get_turf(src)
	src.visible_message("<span class='warning'>\The [src] splits open.</span>")
	for(var/atom/movable/A in contents)
		A.forceMove(T)
	return ..()
