#define WHITELISTFILE "config/jobwhitelist.txt"

var/list/whitelist = list()
var/list/jobwhitelist = list(
	"Centcom Agent",
	"Supplies Manager"
	)

/hook/startup/proc/loadWhitelist()
	if(config.usewhitelist)
		load_whitelist()
	return 1

/proc/load_whitelist()
	var/text = file2text("config/jobwhitelist.txt")
	if (!text)
		log_misc("Failed to load config/jobwhitelist.txt")
	else
		whitelist = text2list(text, "\n")

/proc/check_whitelist(mob/M /*, var/rank*/)
	if(!whitelist)
		return 0
	return ("[M.ckey]" in whitelist)

/proc/is_whitelisted(mob/M, var/rank)
	if(!config.usewhitelist)
		return 1
	if(check_rights(R_ADMIN, 0))
		return 1
	if(!whitelist)
		return 1
	if(!(rank in jobwhitelist))
		return 1
	if(M && rank)
		for (var/s in whitelist)
			if(findtext(s,"[M.ckey] - [rank]"))
				return 1
			if(findtext(s,"[M.ckey] - All"))
				return 1
	return 0


/var/list/alien_whitelist = list()

/hook/startup/proc/loadAlienWhitelist()
	if(config.usealienwhitelist)
		load_alienwhitelist()
	return 1

/proc/load_alienwhitelist()
	var/text = file2text("config/alienwhitelist.txt")
	if (!text)
		log_misc("Failed to load config/alienwhitelist.txt")
	else
		alien_whitelist = text2list(text, "\n")

//todo: admin aliens
/proc/is_alien_whitelisted(mob/M, var/species)
	if(!config.usealienwhitelist)
		return 1
	if(species == "human" || species == "Human")
		return 1
	if(check_rights(R_ADMIN, 0))
		return 1
	if(!alien_whitelist)
		return 0
	if(M && species)
		for (var/s in alien_whitelist)
			if(findtext(s,"[M.ckey] - [species]"))
				return 1
			if(findtext(s,"[M.ckey] - All"))
				return 1
	return 0

#undef WHITELISTFILE
