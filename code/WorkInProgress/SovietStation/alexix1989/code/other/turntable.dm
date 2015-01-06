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
	emagged = 0
	var/list/songs = list ("Barstotzka"='sound/turntable/ArstotzkaAnthemFromEastGrestintoOrvechVonor.ogg',
		"Trying to Stay Alive"='sound/turntable/BeeGeesStayinAlive.ogg',
		"Song About Station Engineer"='sound/turntable/Engineer.ogg',
		"Chok-Chok"='sound/turntable/klemens.ogg',
		"Escape from Brig"='sound/turntable/LatchoDromLaVerdine.ogg',
		"Love"='sound/turntable/LudwigVanBeethovenFurElise.ogg',
		"Everybody Loves Moons"='sound/turntable/LudwigvanBeethovenTheMoonlightSonata.ogg',
		"Reloading an AI"='sound/turntable/PPKReload.ogg',
		"Soviet March"='sound/turntable/RedAlert3FullSovietMarch.ogg',
		"Soviet March Solo"='sound/turntable/RedAlert3UprisingSolo.ogg',
		"Sunshine"='sound/turntable/SpaceMagicFly.ogg',
		"In my Mind..."='sound/turntable/ThePixiesWheresMyMind.ogg',
		"Das Backerei und Serioja"='sound/turntable/TIKSeroja.ogg')
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
	if (istype(W, /obj/item/weapon/card/emag) && !emagged)
		src.emagged = 1
		user << "You short out the product lock on [src]"
		for(var/i in hacked_songs) {
			songs[i] = hacked_songs[i]
		}
		return
	if(istype(W, /obj/item/weapon/card) && currently_selected)
		var/obj/item/weapon/card/C = W
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		var/datum/money_account/CH = get_account(C.associated_account_number)
		if (CH) // Only proceed if card contains proper account number.
			if(!CH.suspended)
				var/transaction_amount = 2
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
					enableMusic(currently_selected)
					currently_selected = 0
				else
					usr << "\icon[src]<span class='warning'>You don't have that much money!</span>"
			else
				usr << "\icon[src]<span class='warning'>Error: Unable to access your account. Please contact technical support if problem persists.</span>"
		else
			usr << "\icon[src]<span class='warning'>Connected account has been suspended.</span>"
		var/t = "<body background=turntable.png ><br><br><br><br><br><br><br><br><br><br><br><br><div align='center'>"
		t += "<A href='?src=\ref[src];off=1'><font color='maroon'>T</font><font color='geen'>urn</font> <font color='red'>Off</font></A>"
		t += "<table border='0' height='25' width='300'><tr>"
		for (var/i = 1, i<=(songs.len), i++)
			var/check = i%2
			t += "<td><A href='?src=\ref[src];tryOn=[i]'><font color='maroon'>[copytext(songs[i],1,2)]</font><font color='purple'>[copytext(songs[i],2)]</font></A></td>"
			if(!check)
				t += "</tr><tr>"
		t += "</tr></table></div></body>"
		usr << browse(t, "window=turntable;size=500x636;can_resize=0")
		onclose(usr, "turntable")
	return

/obj/machinery/party/turntable/attack_hand(mob/living/user as mob)
	if (..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)

	var/t = "<body background=turntable.png ><br><br><br><br><br><br><br><br><br><br><br><br><div align='center'>"
	t += "<A href='?src=\ref[src];off=1'><font color='maroon'>T</font><font color='geen'>urn</font> <font color='red'>Off</font></A>"
	t += "<table border='0' height='25' width='300'><tr>"

	for (var/i = 1, i<=(songs.len), i++)
		var/check = i%2
		t += "<td><A href='?src=\ref[src];tryOn=[i]'><font color='maroon'>[copytext(songs[i],1,2)]</font><font color='purple'>[copytext(songs[i],2)]</font></A></td>"
		if(!check)
			t += "</tr><tr>"
	t += "</tr></table></div></body>"
	user << browse(t, "window=turntable;size=500x636;can_resize=0")
	onclose(user, "turntable")
	currently_selected = 0
	return
/obj/machinery/party/turntable/proc/enableMusic(index)
	if(src.playing == 1)
		off()
	if(src.playing == 0 && index)
		icon_state = "On"
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
		while(playing == 1)
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
/obj/machinery/party/turntable/Topic(href, href_list)
	..()

	if( href_list["back"])
		currently_selected = 0
		usr.set_machine(src)
		src.add_fingerprint(usr)
		var/t = "<body background=turntable.png ><br><br><br><br><br><br><br><br><br><br><br><br><div align='center'>"
		t += "<A href='?src=\ref[src];off=1'><font color='maroon'>T</font><font color='geen'>urn</font> <font color='red'>Off</font></A>"
		t += "<table border='0' height='25' width='300'><tr>"

		for (var/i = 1, i<=(songs.len), i++)
			var/check = i%2
			t += "<td><A href='?src=\ref[src];tryOn=[i]'><font color='maroon'>[copytext(songs[i],1,2)]</font><font color='purple'>[copytext(songs[i],2)]</font></A></td>"
			if(!check) t += "</tr><tr>"
		t += "</tr></table></div></body>"
		usr << browse(t, "window=turntable;size=500x636;can_resize=0")
		onclose(usr, "turntable")
		return
	if( href_list["tryOn"])
		currently_selected = href_list["tryOn"]
		usr << browse("<body><center>Swipe your card, please<br><br><A href='?src=\ref[src];back=1'>Back</A></center></body>", "window=turntable;size=500x636;can_resize=0")
		return

	if( href_list["on"])
		enableMusic(href_list["on"])
		return

	if( href_list["off"] )
		off()

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