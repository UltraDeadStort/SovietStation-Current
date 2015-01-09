
/datum/job/centcom
	title = "Centcom Agent"
	flag = CENTCOMAGENT
	department_flag = ENGSEC
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "Nanotrasen officials and Corporate Regulations"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/centcom
	req_admin_notify = 0
	access = list(access_cent_general, access_cent_creed, access_lawyer, access_court, access_sec_doors, access_maint_tunnels)
	minimal_access = list(access_cent_general, access_cent_creed, access_lawyer, access_court, access_sec_doors, access_maint_tunnels)
	minimal_player_age = 14

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_sec(H), slot_l_ear)
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/internalaffairs(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/internalaffairs(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses/big(H), slot_glasses)
		H.equip_to_slot_or_del(new /obj/item/device/pda/lawyer(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/briefcase(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1


/datum/job/centcom/supplies
	title = "Supplies Manager"
	flag = SUPPLIESMANAGER
	total_positions = 1
	spawn_positions = 1
	supervisors = "Nanotrasen officials and Corporate Regulations"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/centcom
	req_admin_notify = 0
	access = list(access_cent_general, access_cent_creed, access_cent_storage, access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_access = list(access_cent_general, access_cent_creed, access_cent_storage, access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station)
	minimal_player_age = 14

	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargo(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/quartermaster(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/glasses/sunglasses(H), slot_glasses)
		H.equip_to_slot_or_del(new /obj/item/weapon/clipboard(H), slot_l_hand)
		if(H.backbag == 1)
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
		else
			H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
		return 1