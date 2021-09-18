###############################################################################################
#
#	Name		:
#		TCL-Youtube-Link.tcl
#
#	Description	:
#		This script retrieves information about Youtube titles using Youtube API V3.
#		Allows you to search for titles with keywords
#		It listens to youtube links on trade shows and displays title information
#
#		Ce script récupère des informations sur les titres Youtube à l'aide de l'API Youtube V3.
#		Permet de rechercher des titres avec des mots clefs
#		Il écoute les liens youtube sur les salons et affiche les informations des titres
#
#	Donation	:
#		https://github.com/MalaGaM/DONATE
#
#	Auteur		:
#		MalaGaM @ https://github.com/MalaGaM
#
#	Website		:
#		https://github.com/MalaGaM/TCL-Youtube-Link
#
#	Support		:
#		https://github.com/MalaGaM/TCL-Youtube-Link/issues
#
#	Docs		:
#		https://github.com/MalaGaM/TCL-Youtube-Link/wiki
#
#	Thanks to	:
#		m00nie		-	base code								:	www.m00nie.com
#		Imhotep		-	ask and details							:	from www.eggdrop.fr
#		CrazyCat	-	community french and help of eggdrop	:	https://www.eggdrop.fr
#		MenzAgitat	-	tips/toolbox							:	https://boulets.eggdrop.fr
#
###############################################################################################

# Décharger si déjà charger : Reset du script
if { [::tcl::info::commands ::YouTubeLink::Script:Unload] eq "::YouTubeLink::Script:Unload" } { ::YouTubeLink::Script:Unload }

namespace eval ::YouTubeLink {
	variable API
	variable YTDB
	variable CMDIRC
	variable Annonce
	variable Throttled
	variable Script
	variable Bind
	variable Channels

	######################################################################################
	### Configuration Utilisateur     *** (Modifier les variables dans cette sections) ***
	######################################################################################
	# Cette clé est la vôtre et devrait rester secrète. 
	# Pour obtenir une clef visitez :
	#	https://developers.google.com/youtube/v3/
	#
	set API(Key)				"<YOUR_API_KEY>"

	# Après combien de secondes décide-t-on que le site web utilisé par le script
	# pour afficher les définitions est offline (ou trop lent) en l'absence de
	# réponse de sa part ?
	set API(Timeout)			10

	# Nombre de resultats maximun
	set API(Max_Resultats)		5

	# Liste des commandes aux quelles le script doit répondre :
	set CMDIRC(Public)			"!yt !youtube"

	# Autorisations pour la commande publique
	#	Plus d'information sur https://wiki.eggdrop.fr/Flags
	set CMDIRC(Public_Flags)	"-"

	# Configurer dans la variable Annonce(Prefix) ce que vous desire voir devant les message :
	set Annonce(Prefix)			"\002\00301,00You\00300,04Tube\003\002"

	# Configurer dans la variable Annonce(Message) l'annonce de sortie voulu lors d'un lien url youtube
	#
	# Les variables disponibles :
	#
	#	\${MUSIC_TITLE}		: Affiche le titre de la musique
	#	\${MUSIC_CHANNEL}	: Affiche le nom de la chaine youtube
	#	\${MUSIC_DURATION}	: Affiche la durée du titre
	#	\${MUSIC_PUBLISH}	: Affiche quand le titre a été publié
	#	\${MUSIC_VIEWED}	: Affiche le nombre de fois que le titre a été vue/lue
	#

	set Annonce(Message)		"\002\00307\${MUSIC_TITLE}\002 \00305(\00314Durée:\00307 \${MUSIC_DURATION}\00305)-(\00314Nombre de vues: \00307\${MUSIC_VIEWED}\00305)-(\00314Chaine:\00307 \${MUSIC_CHANNEL}\00305)-(\00314Publiée:\00307 \$MUSIC_PUBLISH\00305)\003"

	# Configurer dans la variable Annonce(Message_Search) l'annonce de sortie voulu lors d'une recherche youtube
		#
	# Les variables disponibles :
	#
	#	\${ITEM_NUM}			: Affiche la numerotation du titre trouvé
	#	\${ITEM_TITLE}	: Affiche le nom/descriptions du titre trouvé
	#	\${ITEM_LINK}			: Affiche l'adresse url du titre trouvé
	#
	set Annonce(Message_Search)	"\002\00305\${ITEM_NUM}\00314)\003 \00307\${ITEM_TITLE} \002\00314-\003 \00305\${ITEM_LINK}\003"

	# Message en cas de aucun resultat lors d'une recherche
	set Annonce(Null_Resultat)	"\002\00305\Aucun Resultat trouvé.\003"
	
	# Chaine de caractere de séparation entre deux titres :
	set Annonce(Split_Char)		" \00304|\003 "

	# Nombre de lien par annonce
	set Annonce(Max_Links)		2

	# Format d'affichage de la date de publication du titre
	#	Plus information sur https://www.tcl.tk/man/tcl/TclCmd/clock.htm#M26
	#	Exemple:	"%a %d %b %Y à %H:%M"
	set Format(Date)			"%d/%m/%Y"

	# La region de la date de publication. en france utilisez "fr"
	#	Plus d'information sur https://www.tcl.tk/man/tcl/TclCmd/clock.htm#M20
	set Format(Date_locale)		"fr"

	# Liste des salons où le script sera active
	#	mettre "*" pour tout les salons
	# Exemple pour autoriser #channel1 et #channel2
	#	set Channels(Allow)				" #channel1  #channel2"
	set Channels(Allow)			"*"
	
	
	######################################################################################
	###  Fin de la Configuration Utilisateur
	######################################################################################
	

	######################################################################################
	### Configuration avancées
	######################################################################################

	# URL (n'y touchez pas à moins d'avoir une bonne raison de le faire)
	set API(URL)					"https://www.googleapis.com/youtube/v3"

	# User client du navigateur API
	set API(UserAgent)				"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"

	# The two variables below control throttling in seconds. First is per user, second is per channel third is per link
	set Throttled(User)				5
	set Throttled(Channel)			5
	set Throttled(Link)				5
	
	# Valeur du scripts :
	set Script(Name)				"TCL-YouTube-Link"
	set Script(Auteur)				"MalaGaM <MalaGaM.ARTiSPRETiS@GMail.Com>"
	set Script(Version)				"2.6.1"
	set Script(Debug)				0
	
	set Bind(RegExp_URLMatching)	{(?:http(?:s|).{3}|)(?:www.|)(?:youtube.com\/watch\?.*v=|youtu.be\/)([\w-]{11})}
	set Bind(Matching)				{*youtu*be*/*}

	set Annonce(URL_YT)				"https://youtu.be/"
	###############################################################################
	### Fin de la Configuration avancées
	###############################################################################
}

###############################################################################
### Procédure principale
###############################################################################
proc ::YouTubeLink::add_thousand_separators {value} {
	# https://www.boulets.oqp.me/tcl/routines/tcl-toolbox-0001.html
	return [::tcl::string::trimleft [::tcl::string::reverse [regsub -all {...} [::tcl::string::reverse $value] {&.}]] "."]
}
proc ::YouTubeLink::DEBUG { text } {
	variable Script
	if { $Script(Debug) } { putlog "\[$Script(Name)\] $text" }
}
proc ::YouTubeLink::INIT { } {
	variable Script
	variable API
	variable CMDIRC
	variable Bind
	
	#############################################################################
	### Initialisation
	#############################################################################

	if { [package vcompare [regexp -inline {^[[:digit:]\.]+} $::version] 1.6.20] == -1 } { putloglev o * "\00304\[$Script(Name) - erreur\]\003 La version de votre Eggdrop est\00304 ${::version}\003; $Script(Name) ne fonctionnera correctement que sur les Eggdrops version 1.6.20 ou supérieure." ; return }
	if { [::tcl::info::tclversion] < 8.5 } { putloglev o * "\00304\[$Script(Name) - erreur\]\003 $Script(Name) nécessite que Tcl 8.5 (ou plus) soit installé pour fonctionner. Votre version actuelle de Tcl est\00304 ${::tcl_version}\003." ; return }
	if { [catch { package require tls 1.7.11 }] } { putloglev o * "\00304\[$Script(Name) - erreur\]\003 $Script(Name) nécessite le package tls 1.7 (ou plus) pour fonctionner. Le chargement du script a été annulé." ; return }
	if { [catch { package require http 2.8.9 }] } { putloglev o * "\00304\[$Script(Name) - erreur\]\003 $Script(Name) nécessite le package http 2.9 (ou plus) pour fonctionner. Le chargement du script a été annulé." ; return }
	if { [catch { package require json 1.3 }] } { putloglev o * "\00304\[$Script(Name) - erreur\]\003 $Script(Name) nécessite le package json 1.3 (ou plus) pour fonctionner. Le chargement du script a été annulé." ; return }
	if { [catch { package require clock::iso8601 0.1 }] } { putloglev o * "\00304\[$Script(Name) - erreur\]\003 $Script(Name) nécessite le package clock::iso8601 0.1 (ou plus) pour fonctionner. Le chargement du script a été annulé." ; return }
	
	::http::config -useragent $API(UserAgent)
	###############################################################################
	### Binds
	###############################################################################
	foreach b $CMDIRC(Public) { bind pub $CMDIRC(Public_Flags) $b ::YouTubeLink::IRC:Search }
	bind pubm $CMDIRC(Public_Flags) "% $Bind(Matching)" ::YouTubeLink::IRC:Listen:Links
	bind evnt - prerehash ::YouTubeLink::Script:Unload

	putlog "$Script(Name) $Script(Version) by $Script(Auteur) loaded."
}
proc ::YouTubeLink::Script:Unload {args} {
	variable Script
	putlog "Désallocation des ressources de ${Script(Name)} ..."
	foreach binding [lsearch -inline -all -regexp [binds *[set ns [::tcl::string::range [namespace current] 2 end]]*] " \{?(::)?$ns"] {
		putlog "unbind [lindex $binding 0] [lindex $binding 1] [lindex $binding 2] [lindex $binding 4]"
	}
	foreach running_utimer [utimers] {
		if { [::tcl::string::match "*[namespace current]::*" [lindex $running_utimer 1]] } { killutimer [lindex $running_utimer 2] }
	}
	namespace delete [namespace current] ::[namespace current]
}
proc ::YouTubeLink::ThrottleCheck { nick chan link } {
	variable Throttled
	if { [info exists ::YouTubeLink::Throttled($link)]} {
		::YouTubeLink::DEBUG "::YouTubeLink::ThrottleCheck search term or video id: $link, is Throttled at the moment"
		return 1
	} elseif {[info exists ::YouTubeLink::Throttled($chan)]} {
		::YouTubeLink::DEBUG  "::YouTubeLink::ThrottleCheck Channel $chan is Throttled at the moment"
		return 1
	} elseif {[info exists ::YouTubeLink::Throttled($nick)]} {
		::YouTubeLink::DEBUG  "::YouTubeLink::ThrottleCheck User $nick is Throttled at the moment"
		return 1
	} else {
		set ::YouTubeLink::Throttled($nick) [utimer $Throttled(User) [list unset ::YouTubeLink::Throttled($nick)]]
		set ::YouTubeLink::Throttled($chan) [utimer $Throttled(Channel) [list unset ::YouTubeLink::Throttled($chan)]]
		set ::YouTubeLink::Throttled($link) [utimer $Throttled(Link) [list unset ::YouTubeLink::Throttled($link)]]
		return 0
	}
}
proc ::YouTubeLink::API:ControlInfo { URL_DATA } {
	if { [dict exists ${URL_DATA} error] } {
       return -code error [dict get [dict get ${URL_DATA} error] message]
	}
	return ${URL_DATA}
}
proc ::YouTubeLink::API:GetInfo { URL_Link } {
	variable API
	::http::register https 443 [list ::tls::socket -tls1 1]
	array set httpconfig	[::http::config]
	::http::config -urlencoding utf-8 -useragent $API(UserAgent)
	# On remplace les caractères spéciaux par leur équivalent hexadécimal pour
	# pouvoir être utilisés dans l'url.
	# set arg [::http::mapReply $arg]

	# on restaure l'urlencoding comme il était avant qu'on y touche
	::http::config -urlencoding $httpconfig(-urlencoding)
	if { [catch { set token [::http::geturl ${URL_Link} -timeout [expr $API(Timeout) * 1000]] }] } {
		::YouTubeLink::DEBUG  "::YouTubeLink::API:GetInfo \00314La connexion à \00312\037[set URL_Link]\037\003\00314 n'a pas pu être établie. Il est possible que le site rencontre un problème technique.\003"
	} elseif {[::http::status ${token}] eq "ok"} {
		# on extrait la partie qui nous intéresse et sur laquelle on va travailler
		set received_data [::http::data ${token}]
		::http::cleanup ${token}
		::http::unregister https
		return [json::json2dict ${received_data}]
	}

}
proc ::YouTubeLink::IRC:Search { nick uhost hand chan text } {
	variable YTDB
	variable API
	variable Channels
	variable Annonce
	variable CMDIRC
	if { $Channels(Allow) != "*" && [lsearch -nocase $Channels(Allow) $chan] == "-1" } { return }
	# !yt info 1
	if {
			[string match -nocase "info" [lindex $text 0]]	\
			&& [string is digit -strict [lindex $text 1]]	\
			&& [lindex $text 2] == ""						\
			&& [info exists YTDB([lindex $text 1])]
	} {
		set NUM	[lindex $text 1]
		::YouTubeLink::IRC:Listen:Links $nick $uhost $hand $chan "${Annonce(URL_YT)}$YTDB($NUM)"
		return 
	}

	if { [::YouTubeLink::ThrottleCheck $nick $chan $text] } {
		::YouTubeLink::DEBUG  "::YouTubeLink::IRC:Search INFO: ThrottleCheck protection: $nick $chan $text"
		return
	}
	::YouTubeLink::DEBUG "::YouTubeLink::IRC:Search is running with $text from $chan/$nick"

	set URL_Link			"${API(URL)}/search?part=snippet&fields=items(id(videoId),snippet(title))&[::http::formatQuery key $API(Key) maxResults [expr $API(Max_Resultats) + 1] q [lrange [split $text] 0 end]]"
	putlog $URL_Link
	set URL_DATA			[::YouTubeLink::API:GetInfo ${URL_Link}]
	if { [ catch {
    	::YouTubeLink::API:ControlInfo ${URL_DATA}
	} ERROR_MSG ] } {
		puthelp "PRIVMSG $chan :${Annonce(Prefix)} ERROR: ${ERROR_MSG}"
		return 
	}
	set ITEMS_DATA			[dict get ${URL_DATA} items]
	set ITEMS_DATA_LENGTH	[llength ${ITEMS_DATA}]
	set ITEM_NUM			0
	set LOOP_NUM			0
	if { ${ITEMS_DATA_LENGTH} == 0 } {
		puthelp "PRIVMSG $chan :${Annonce(Prefix)} ${Annonce(Null_Resultat)}"
		return
	}
	for { set i 0 } { $i < ${ITEMS_DATA_LENGTH} } { incr i } {
		set ITEM_ID		[lindex ${ITEMS_DATA} $i 1 1];
		if { $ITEM_ID == "" } { continue }
		
		incr ITEM_NUM
		incr LOOP_NUM
		set YTDB($ITEM_NUM)	${ITEM_ID}
		set TMP_TITLE		[encoding convertfrom [lindex ${ITEMS_DATA} $i 3 1]];
		set ITEM_TITLE		[string map -nocase [list "&amp;" "&" "&#39;" "'" "&quot;" "\""] $TMP_TITLE];
		set ITEM_LINK		"${Annonce(URL_YT)}${ITEM_ID}";
		append output 		[subst $Annonce(Message_Search)] ${Annonce(Split_Char)}
		if { $LOOP_NUM == ${Annonce(Max_Links)} } {
			set LOOP_NUM	0
			puthelp "PRIVMSG $chan :${Annonce(Prefix)} [string trimright $output ${Annonce(Split_Char)}]"
			set output		""
		}
	}
	if { $output != "" } {
		puthelp "PRIVMSG $chan :${Annonce(Prefix)} [string trimright $output ${Annonce(Split_Char)}]"
	}
	set CMD 	[lindex $CMDIRC(Public) 0]
	puthelp "PRIVMSG $chan :${Annonce(Prefix)} Info: $CMD info <num>"
}

proc ::YouTubeLink::IRC:Listen:Links {nick uhost hand chan text} {
	variable Bind
	variable API
	variable Annonce
	variable Format
	variable Channels
	if { $Channels(Allow) != "*" && [lsearch -nocase $Channels(Allow) $chan] == "-1" } { return }
	::YouTubeLink::DEBUG "::YouTubeLink::IRC:Listen:Links is running with $text from $chan/$nick"

	if { ![regexp -nocase -- $Bind(RegExp_URLMatching) $text URL_Link id] } {
		::YouTubeLink::DEBUG "::YouTubeLink::IRC:Listen:Links ERREUR: regexp $Bind(RegExp_URLMatching) not match $text sur $chan"
		return
	}
	if { [::YouTubeLink::ThrottleCheck $nick $chan $id] } {
		::YouTubeLink::DEBUG  "::YouTubeLink::IRC:Listen:Links INFO: ThrottleCheck protection: $nick $chan $text"
		return
	}
	::YouTubeLink::DEBUG "::YouTubeLink::IRC:Listen:Links info: url is: ${URL_Link} and id is: $id"
	set URL_Link				"${API(URL)}/videos?id=$id&part=snippet,statistics,contentDetails&fields=items(snippet(title,channelTitle,publishedAt),statistics(viewCount),contentDetails(duration))&[::http::formatQuery key $API(Key)]"
	set URL_DATA				[::YouTubeLink::API:GetInfo ${URL_Link}]
	if { [ catch {
    	::YouTubeLink::API:ControlInfo ${URL_DATA}
	} ERROR_MSG ] } {
		puthelp "PRIVMSG $chan :${Annonce(Prefix)} ERROR: ${ERROR_MSG}"
		return 
	}
	set ITEMS_DATA				{*}[dict get ${URL_DATA} items]
	set MUSIC_TITLE				[encoding convertfrom [dict get ${ITEMS_DATA} snippet title]]
	set MUSIC_PUBLISH_iso8601	[dict get ${ITEMS_DATA} snippet publishedAt]

	set MUSIC_PUBLISH			[clock format [::clock::iso8601 parse_time $MUSIC_PUBLISH_iso8601] -format $Format(Date) -locale $Format(Date_locale)]
	set MUSIC_CHANNEL			[encoding convertfrom [dict get ${ITEMS_DATA} snippet channelTitle]]
	set MUSIC_DURATION			[::YouTubeLink::FCT:ISO8601:TO:DURATION [dict get ${ITEMS_DATA} contentDetails duration]]
	set MUSIC_VIEWED			[::YouTubeLink::add_thousand_separators [dict get ${ITEMS_DATA} statistics viewCount]]
	set isotime					[lindex ${ITEMS_DATA} 0 3 1]
	set views					[lindex ${ITEMS_DATA} 0 5 1]
	puthelp "PRIVMSG $chan :${Annonce(Prefix)} [subst $Annonce(Message)]"
}

proc ::YouTubeLink::FCT:ISO8601:TO:DURATION { isotime } {
	regsub -all {PT|S} $isotime "" isotime
	regsub -all {H|M} $isotime ":" isotime
	if { [string index $isotime end-1] == ":" } {
		set sec		[string index $isotime end]
		set trim	[string range $isotime 0 end-1]
		set isotime	${trim}0$sec
	} elseif { [string index $isotime 0] == "0" } {
		set isotime	"stream"
	} elseif { [string index $isotime end-2] != ":" } {
		set isotime	"${isotime}s"
	}
	return $isotime
}
# Chargement du script
::YouTubeLink::INIT

