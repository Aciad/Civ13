/obj/structure/heatsource
	name = "iron furnace"
	desc = "A big iron furnace. Can be used to power external-powered engines."
	icon = 'icons/obj/engines32.dmi'
	icon_state = "furnace_open_off"
	anchored = TRUE
	density = TRUE
	opacity = FALSE
	var/fuel = 0
	var/on = FALSE
	not_movable = FALSE
	not_disassemblable = TRUE

/obj/structure/heatsource/New()
	..()
	do_light()

/obj/structure/heatsource/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (user.a_intent == I_HELP)
		if (istype(W, /obj/item/weapon/wrench) || (istype(W, /obj/item/weapon/hammer)))
			if (istype(W, /obj/item/weapon/wrench))
				visible_message("<span class='warning'>[user] starts to [anchored ? "unsecure" : "secure"] \the [src] [anchored ? "from" : "to"] the ground.</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 100, TRUE)
				if (do_after(user,50,src))
					visible_message("<span class='warning'>[user] [anchored ? "unsecures" : "secures"] \the [src] [anchored ? "from" : "to"] the ground.</span>")
					anchored = !anchored
					return
			else if (istype(W, /obj/item/weapon/hammer))
				visible_message("<span class='warning'>[user] starts to deconstruct \the [src].</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 100, TRUE)
				if (do_after(user,50,src))
					visible_message("<span class='warning'>user] deconstructs \the [src].</span>")
					qdel(src)
					return
		else if (istype(W, /obj/item/stack/ore/coal))
			fuel += (180)*W.amount
			user << "You refuel the [src]."
			qdel(W)
			return
		else if (istype(W, /obj/item/stack/material/wood))
			fuel += (60)*W.amount
			user << "You refuel the [src]."
			qdel(W)
			return

		else if  (istype(W, /obj/item))
			if (W.flammable)
				if (istype(W, /obj/item/stack))
					var/obj/item/stack/ST = W
					fuel += 25*ST.amount
				else
					fuel += 25
				user << "You place \the [W] in \the [src], refueling it."
				qdel(W)
				return
			else
				if (on)
					user << "You throw \the [W] into the [src], melting it."
					qdel(W)
					return
	..()
/obj/structure/heatsource/proc/do_light()
	if (on)
		fuel = (fuel-1)
		if (fuel <= 0)
			on = FALSE
			icon_state = "furnace_open_off"
			set_light(0)
	spawn(10)
		do_light()

/obj/structure/heatsource/attack_hand(mob/user as mob)
	if (!on && fuel > 0)
		user << "You light \the [src]."
		on = TRUE
		icon_state = "furnace_open_on"
		set_light(2)
		return
	else
		user << "You put out \the [src]."
		on = FALSE
		icon_state = "furnace_open_off"
		set_light(0)
		return