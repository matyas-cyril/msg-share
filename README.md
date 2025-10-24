# msg-share

## Dépendances
```
$ sudo apt install make docker-ce docker-ce-cli containerd.io python3-venv 
```
## Commandes

``` bash
# Déployer une plateforme (tous les containers, installer ansible / venv, conf LDAP, conf Dovecot)
$ make all

# Supprimer les containers, dossiers partagés, venv)
$ make clean

# Supprimer les containers, dossiers partagés, venv) + les images dockers
$ make purge

# Déployer une architecture + des données pour des tests
$ make demo
```

``` bash
$ make keycloak
$ make rm_keycloak
$ make certif-keycloak
$ make rm_certif-keycloak
$ make ansible
$ make rm_ansible
$ make murder
$ make rm_murder
$ make frontend
$ make rm_frontend
$ make backend
$ make rm_backend
$ make backend-save
$ make rm_backend-save
$ make smtp
$ make rm_smtp
$ make dovecot
$ make rm_dovecot
$ make ldap
$ make rm_ldap
$ make postgres
$ make rm_postgres
$ make webmail
$ make rm_webmail
$ make gestion
$ make rm_gestion
$ make adminer
$ make rm_adminer
$ make prometheus
$ make rm_prometheus
```

## WebUI

``` bash
# Webmail (Roundcube)
http://localhost:20080
```
``` bash
# Prometheus
http://localhost:29090
```
``` bash
# Keycloak
https://localhost:38443
```