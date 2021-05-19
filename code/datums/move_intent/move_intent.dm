/decl/move_intent
	var/name
	var/flags = 0
	var/move_delay = 1
	var/footstep_interval = 1

/decl/move_intent/walk
	name = "Walk"
	flags = MOVE_INTENT_DELIBERATE

/decl/move_intent/walk/Initialize()
	. = ..()
	move_delay = CONFIG_GET(number/walk_speed) + 7


/decl/move_intent/run
	name = "Run"
	flags = MOVE_INTENT_EXERTIVE | MOVE_INTENT_QUICK
	footstep_interval = 2

/decl/move_intent/run/Initialize()
	. = ..()
	move_delay = CONFIG_GET(number/run_speed) + 1
