./sound/turntable/test
	file = 'sound/turntable/TestLoop1.ogg'
	falloff = 2
	repeat = 1

/mob/var/music = 0

/obj/machinery/party/turntable
	name = "Jukebox"
	desc = "A jukebox is a partially automated music-playing device, usually a coin-operated machine, that will play a patron's selection from self-contained media."
	icon = 'code/WorkInProgress/SovietStation/alexix1989/icons/JukeBox.dmi'
	icon_state = "Off"
	//var/list/random_icon_states = list("Juke")
	var/playing = 0
	anchored = 1
	density = 1
	var/currently_selected = 0
	var/currently_playing = 0
	emagged = 0
	var/locked = 1
	var/action = null
	var/list/songs = list (
	"Track #1"='sound/turntable/track1.ogg',
	"Track #2"='sound/turntable/track2.ogg',
	"Track #3"='sound/turntable/track3.ogg',
	"Track #4"='sound/turntable/track4.ogg',)
	var/list/hacked_songs = list (
		"Space Asshole"='sound/turntable/SpaceAsshole.ogg'
		)

/obj/machinery/party/turntable/New()
	..()
	sleep(2)
	new /sound/turntable/test(src)
	return

/obj/machinery/party/turntable/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/party/turntable/attackby(obj/item/weapon/W as obj, mob/user as mob)
	usr.set_machine(src)
	if (istype(W, /obj/item/weapon/card/emag) && !emagged)
		src.emagged = 1
		src.locked = 0
		user << "You short out the product lock on [src]"
		flick("Emag_on", src)
		sleep(6)
		if(playing) icon_state = "Emag_hacked_on"
		else icon_state = "Off"
		for(var/i in hacked_songs) {
			songs[i] = hacked_songs[i]
		}
		return
	if(istype(W, /obj/item/weapon/card) && action != null)
		var/obj/item/weapon/card/C = W
		var/datum/money_account/CH = get_account(C.associated_account_number)
		if(action == "on_mus")
			visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
			if (CH) // Only proceed if card contains proper account number.
				if(!CH.suspended)
					var/transaction_amount = 10
					if(transaction_amount <= CH.money)
						CH.money -= transaction_amount
						vendor_account.money += transaction_amount
						var/datum/transaction/T = new()
						T.target_name = "(via [src.name])"
						T.purpose = "Purchase of [copytext(songs[currently_selected],1,2)]"
						if(transaction_amount > 0)
							T.amount = "([transaction_amount])"
						else
							T.amount = "[transaction_amount]"
						T.source_terminal = src.name
						T.date = current_date_string
						T.time = worldtime2text()
						CH.transaction_log.Add(T)
						T = new()
						T.target_name = CH.owner_name
						T.purpose = "Purchase of [copytext(songs[currently_selected],1,2)]"
						T.amount = "[transaction_amount]"
						T.source_terminal = src.name
						T.date = current_date_string
						T.time = worldtime2text()
						action = null
						var/index = currently_selected
						currently_selected = 0
						currently_playing = index
						show_main_menu()
						enableMusic(index)
					else
						usr << "\icon[src]<span class='warning'>You don't have that much money!</span>"
				else
					usr << "\icon[src]<span class='warning'>Error: Unable to access your account. Please contact technical support if problem persists.</span>"
			else
				usr << "\icon[src]<span class='warning'>Connected account has been suspended.</span>"
		if(action == "unlock")
			if(access_bar in C.GetAccess())
				locked = 0
				visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
				action = null
				show_main_menu()
			else
				usr << "\icon[src]<span class='warning'>You have no access.</span>"
				action = null
				show_main_menu()
		if(action == "lock")
			if(access_bar in C.GetAccess())
				locked = 1
				visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
				action = null
				show_main_menu()
			else
				usr << "\icon[src]<span class='warning'>You have no access.</span>"
				action = null
				show_main_menu()
		action = null
/obj/machinery/party/turntable/proc/show_main_menu()
	var/t = "<body background=turntable.png >"
	if(action || currently_selected)
		t+= "<br><center><font color='green'>Swipe your card to "
		if(action == "lock")
			t+= "lock"
		if(action == "unlock")
			t+= "unlock"
		if(currently_selected)
			t += "play music"
		t+= ", please</font></center>"
	else
		t+= "<br><br>"
	t += "<br><br><br><br><br><br>"
	t += "<center><A href='?src=\ref[src];off=1'><font color='red'>Turn Off</font></A></center><br><br><br>"
	t += "<table border='0' height='25' width='300' align='center'><tr>"
	for (var/i = 1, i<=(songs.len), i++)
		var/check = i%2
		t += "<td><center>"
		if (!locked)
			if("[i]" != src.currently_playing)
				t += "<A href='?src=\ref[src];tryOn=[i]'>"
		t += "[copytext(songs[i],1,2)][copytext(songs[i],2)]"
		if (!locked)
			if("[i]" != src.currently_playing)
				t += "</A>"
		t += "</td></center>"
		if(!check)
			t += "</tr><tr>"
	t += "</tr></table><br><center><font size='4'>Price: 10$</font><br><br><br>"
	if(action == "lock" || action == "unlock" || currently_selected)
		t += "<A href='?src=\ref[src];cancel=1'>Cancel</A>"
	else
		switch(locked)
			if(0)
				t += "<A href='?src=\ref[src];lock=1'>Lock</A>"
			if(1)
				t += "<A href='?src=\ref[src];unlock=1'>Unlock</A>"
	t += "</center></body>"
	usr << browse(t, "window=turntable;size=500x636;can_resize=0")
	onclose(usr, "turntable")
/obj/machinery/party/turntable/attack_hand(mob/living/user as mob)
	if (..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	currently_selected = 0
	action = null
	show_main_menu()
	return
/obj/machinery/party/turntable/proc/enableMusic(index)
	if(src.playing == 1)
		off()
		sleep(15)
	if(src.playing == 0 && index)
		currently_playing = index
		icon_state = "On"
		if(emagged) icon_state = "Emag_hacked_on"
		//world << "Should be working..."
		var/sound/S
		S = sound(songs[songs[text2num(index)]])
		S.repeat = 1
		S.channel = 10
		S.falloff = 2
		S.wait = 1
		S.environment = 0
		var/area/A = src.loc.loc:master
		for(var/area/RA in A.related)
			for(var/obj/machinery/party/lasermachine/L in RA)
				L.turnon()
		playing = 1
		while(index == currently_playing && playing==1)
			for(var/mob/M in world)
				var/area/location = get_area(M)
				if((location in A.related) && M.music == 0)
					//world << "Found the song..."
					M << S
					M.music = 1
				else if(!(location in A.related) && M.music == 1)
					var/sound/Soff = sound(null)
					Soff.channel = 10
					M << Soff
					M.music = 0
			sleep(10)
	off()
/obj/machinery/party/turntable/proc/off()
	icon_state = "Off"
	if(src.playing == 1)
		var/sound/S = sound(null)
		S.channel = 10
		S.wait = 1
		for(var/mob/M in world)
			M << S
			M.music = 0
		playing = 0
		var/area/A = src.loc.loc:master
		for(var/area/RA in A.related)
			for(var/obj/machinery/party/lasermachine/L in RA)
				L.turnoff()
	currently_playing = 0
	currently_selected = 0

/obj/machinery/party/turntable/process()
	..()
	if(stat & (POWEROFF|NOPOWER))
		off()

/obj/machinery/party/turntable/Topic(href, href_list)
	..()

	if( href_list["back"])
		show_main_menu()
		return
	if( href_list["tryOn"])
		currently_selected = href_list["tryOn"]
		if(currently_selected == currently_playing)
			return
		action = "on_mus"
		show_main_menu()
	if(href_list["lock"])
		if(emagged)
			show_main_menu()
			return
		action = "lock"
		show_main_menu()
		return
	if(href_list["unlock"])
		action = "unlock"
		show_main_menu()
		return
	if( href_list["on"])
		enableMusic(href_list["on"])
		return

	if( href_list["off"] )
		off()
		show_main_menu()
	if(href_list["cancel"])
		action = null
		currently_selected = 0
		show_main_menu()

/obj/machinery/party/mixer
	name = "mixer"
	desc = "A mixing board for mixing music"
	icon = 'code/WorkInProgress/SovietStation/alexix1989/icons/lasers2.dmi'
	icon_state = "mixer"
	density = 0
	anchored = 1

/obj/machinery/party/lasermachine
	name = "laser machine"
	desc = "A laser machine that shoots lasers."
	icon = 'code/WorkInProgress/SovietStation/alexix1989/icons/lasers2.dmi'
	icon_state = "lasermachine"
	anchored = 1
	var/mirrored = 0

/obj/effects/laser
	name = "laser"
	desc = "A laser..."
	icon = 'code/WorkInProgress/SovietStation/alexix1989/icons/lasers2.dmi'
	icon_state = "laserred1"
	anchored = 1
	layer = 4

/obj/item/lasermachine/New()
	..()

/obj/machinery/party/lasermachine/proc/turnon()
	var/wall = 0
	var/cycle = 1
	var/area/A = get_area(src)
	var/X = 1
	var/Y = 0
	if(mirrored == 0)
		while(wall == 0)
			if(cycle == 1)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.icon_state = "laserred1"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
			if(cycle == 2)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.icon_state = "laserred2"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				Y++
			if(cycle == 3)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y+Y
				F.z = src.z
				F.icon_state = "laserred3"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
	if(mirrored == 1)
		while(wall == 0)
			if(cycle == 1)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred1m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				Y++
			if(cycle == 2)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred2m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++
			if(cycle == 3)
				var/obj/effects/laser/F = new/obj/effects/laser(src)
				F.x = src.x+X
				F.y = src.y-Y
				F.z = src.z
				F.icon_state = "laserred3m"
				var/area/AA = get_area(F)
				var/turf/T = get_turf(F)
				if(T.density == 1 || AA.name != A.name)
					del(F)
					return
				cycle++
				if(cycle > 3)
					cycle = 1
				X++


/obj/machinery/party/lasermachine/proc/turnoff()
	var/area/A = src.loc.loc
	for(var/area/RA in A.related)
		for(var/obj/effects/laser/F in RA)
			del(F)