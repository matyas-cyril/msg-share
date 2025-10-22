#annotation_db: twoskip

#anyoneuseracl: 1 -> no

#auditlog: no -> yes

#defaultsearchtier -> voir le moteur de recherche XAPIAN

## CONF POUR LES SUPPRESSIONS DE BAL
#deletedprefix: DELETED
#delete_mode: delayed
#expunge_mode: delayed
#failedloginpause: 3s
#httpallowcompress: 1

# httpallowtrace: 0 -> Permet l'utilisation de la méthode TRACE. A utlisé uniquement en mode débug car peut faire apparaître des données sensibles !!!

# httpkeepalive: 20s

# imapidlepoll:60s
# imap_inprogress_interval:10s

# iolog: 0
# logtimestamps:0 Inclure dans la télémétrie le nombre de secondes depuis la dernière commande ou réponse.

# mailnotifier ????

# maxlogins_per_host:0
# maxlogins_per_user:0
# maxargssize:0

# mupdate_connections_max:128 -> Murder
# mupdate_workers_max:50
# mupdate_workers_maxspare:10
# mupdate_workers_minspare:2
# mupdate_workers_start:5

# quotawarnpercent:90 Pourcentage à partir 

# search_engine: none -> voir xapian

# serverinfo: on

# sieve_vacation_min_response:3d
# sieve_vacation_max_response:90d
# sieve_maxscriptsize:32K
# sieve_maxscripts:5

# singleinstancestore:1

# specialuse_extra: none
# specialuse_nochildren: \Scheduled \Snooze
# specialuse_protect: \Archive \Drafts \Important \Junk \Sent \Scheduled \Snooze \Trash
# specialusealways: 1

# statuscache:0
# statuscache_db: twoskip


# sync_* : Voir les serveurs de Synchro : sync_ pour de la save ou du bbc

# timeout:32m Durée de l'autologout imap

# Regarder xapian