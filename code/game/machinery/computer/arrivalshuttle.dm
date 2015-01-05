
/obj/item/weapon/circuitboard/arrival_shuttle
	name = "Circuit board (Arrival Shuttle)"
	build_path = /obj/machinery/computer/arrival_shuttle
	origin_tech = "programming=2"

/area/shuttle/arrival_shuttle
	name = "Arrival Shuttle Centcom"
	icon_state = "shuttle"

/area/shuttle/arrival_shuttle_station
	name = "Arrival Shuttle Station"
	icon_state = "shuttle"

/area/shuttle/arrival_shuttle_transit
	name = "Arrival Shuttle Transit"
	icon_state = "shuttle"

var/arrival_shuttle_moving_to_station = 0
var/arrival_shuttle_moving_to_centcom = 0
var/arrival_shuttle_timeleft = 0
var/arrival_shuttle_at_station = 0
var/arrival_shuttle_time = 0
#define ARRIVAL_MOVETIME 600

/obj/machinery/computer/arrival_shuttle
	name = "Arrival Shuttle Console"
	icon = 'icons/obj/computer.dmi'
	icon_state = "shuttle"
	req_access = list()
	circuit = "/obj/item/weapon/circuitboard/arrival_shuttle"
	var/obj/item/device/radio/R

	New()
		..()
		R = new /obj/item/device/radio(src)

	Del()
		del(R)
		..()

	attackby(I as obj, user as mob)
		return src.attack_hand(user)


	attack_ai(var/mob/user as mob)
		return src.attack_hand(user)


	attack_paw(var/mob/user as mob)
		return src.attack_hand(user)


	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/weapon/circuitboard/arrival_shuttle/M = new /obj/item/weapon/circuitboard/arrival_shuttle( A )
				for (var/obj/C in src)
					C.loc = src.loc
				A.circuit = M
				A.anchored = 1

				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					new /obj/item/weapon/shard( src.loc )
					A.state = 3
					A.icon_state = "3"
				else
					user << "\blue You disconnect the monitor."
					A.state = 4
					A.icon_state = "4"

				del(src)
		else
			return src.attack_hand(user)

	attack_hand(var/mob/user as mob)
		if(!src.allowed(user))
			user << "\red Access Denied."
			return
		if(..())
			return
		user.set_machine(src)
		var/dat = "\nLocation: "
		if(arrival_shuttle_moving_to_station || arrival_shuttle_moving_to_centcom)
			dat += "Moving to [arrival_shuttle_moving_to_station ? "Station":"Centcom"]([arrival_shuttle_timeleft] Secs.)<BR>"
		else
			dat += "[arrival_shuttle_at_station ? "Station<BR>\n<A href='?src=\ref[src];sendtocentcom=1'>Send to Centcom</A><BR>":"Centcom<BR>\n<A href='?src=\ref[src];sendtostation=1'>Send to station</A><BR>"]"
		dat += "<A href='?src=\ref[src];asupdate=1'>Update</A>"
		var/datum/browser/B = new(user, "arrivalshuttle", "Arrival Shuttle", 360, 240)
		B.set_content(dat)
		B.open()
		return

	Topic(href, href_list)
		if(..())
			return
		if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
			usr.set_machine(src)
		if (href_list["asupdate"])
			src.updateUsrDialog()
			return
		if (arrival_shuttle_moving_to_station || arrival_shuttle_moving_to_centcom)
			usr << "\red Sync error. Updating."
			src.updateUsrDialog()
			return
		if (href_list["sendtocentcom"])
			if (!arrival_shuttle_at_station)	return
			R.autosay("Shuttle has left the station.", "Arrival Shuttle Computer")
		else if (href_list["sendtostation"])
			if (arrival_shuttle_at_station)		return
		arrival_shuttle_time = world.timeofday + ARRIVAL_MOVETIME
		usr << "\blue The arrival shuttle has been called and will arrive in [(ARRIVAL_MOVETIME/10)] seconds."
		spawn(0)
			arrival_process()
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return

	proc/arrival_process()
		var/area/start_location
		var/area/end_location
		if(!(arrival_shuttle_moving_to_station || arrival_shuttle_moving_to_centcom))
			switch(arrival_shuttle_at_station)
				if(1)
					arrival_shuttle_at_station = 0
					arrival_shuttle_moving_to_centcom = 1
					start_location = locate(/area/shuttle/arrival_shuttle_station)
					end_location = locate(/area/shuttle/arrival_shuttle_transit)
				if(0)
					arrival_shuttle_moving_to_station = 1
					start_location = locate(/area/shuttle/arrival_shuttle)
					end_location = locate(/area/shuttle/arrival_shuttle_transit)
			var/list/dstturfs = list()
			var/throwy = world.maxy
			for(var/turf/T in end_location)
				dstturfs += T
				if(T.y < throwy)
					throwy = T.y
			for(var/turf/T in dstturfs)
				var/turf/D = locate(T.x, throwy - 1, 1)
				for(var/atom/movable/AM as mob|obj in T)
					AM.Move(D)
				if(istype(T, /turf/simulated))
					del(T)
			for(var/mob/living/carbon/bug in end_location)
				bug.gib()
			for(var/mob/living/simple_animal/pest in end_location)
				pest.gib()
			start_location.move_contents_to(end_location)
			for(var/mob/M in end_location)
				if(M.client)
					spawn(0)
						if(M.buckled)
							M << "\red Sudden acceleration presses you into your chair!"
							shake_camera(M, 3, 1)
						else
							M << "\red The floor lurches beneath you!"
							shake_camera(M, 10, 1)
				if(istype(M, /mob/living/carbon))
					if(!M.buckled)
						M.Weaken(3)
		while(arrival_shuttle_time - world.timeofday > 0)
			var/ticksleft = arrival_shuttle_time - world.timeofday
			if(ticksleft > 1e5)
				arrival_shuttle_time = world.timeofday + 10	// midnight rollover
			arrival_shuttle_timeleft = (ticksleft / 10)
			sleep(5)

		if(arrival_shuttle_moving_to_station)
			arrival_shuttle_moving_to_station = 0
			arrival_shuttle_at_station = 1
			start_location = locate(/area/shuttle/arrival_shuttle_transit)
			end_location = locate(/area/shuttle/arrival_shuttle_station)
		else
			arrival_shuttle_moving_to_centcom = 0
			start_location = locate(/area/shuttle/arrival_shuttle_transit)
			end_location = locate(/area/shuttle/arrival_shuttle)

		var/list/dstturfs2 = list()
		var/throwy2 = world.maxy
		for(var/turf/T in end_location)
			dstturfs2 += T
			if(T.y < throwy2)
				throwy2 = T.y
		for(var/turf/T in dstturfs2)
			var/turf/D2 = locate(T.x, throwy2 - 1, 1)
			for(var/atom/movable/AM as mob|obj in T)
				AM.Move(D2)
			if(istype(T, /turf/simulated))
				del(T)
		for(var/mob/living/carbon/bug in end_location)
			bug.gib()
		for(var/mob/living/simple_animal/pest in end_location)
			pest.gib()
		start_location.move_contents_to(end_location)
		for(var/mob/M in end_location)
			if(M.client)
				spawn(0)
					if(M.buckled)
						M << "\red Sudden acceleration presses you into your chair!"
						shake_camera(M, 3, 1)
					else
						M << "\red The floor lurches beneath you!"
						shake_camera(M, 10, 1)
			if(istype(M, /mob/living/carbon))
				if(!M.buckled)
					M.Weaken(3)
		if(arrival_shuttle_at_station)
			R.autosay("Shuttle has docked at the station.", "Arrival Shuttle Computer")
		return