# msg-share

## Dépendances
```
$ sudo apt install make docker-ce docker-ce-cli containerd.io python3-venv 
```
## Commandes

``` bash
# Construire une plateforme de messagerie (Containers Docker + conf Webmail)
$ make construct
```
``` bash
# Supprimer la plateforme de messagerie (Containers Docker + volumes, ansible, VENV, dossier partagé)
$ make destroy
```
``` bash
# Supprimer toute la plateforme de messagerie (make destroy) + les images + conf réseau + volumes
$ make purge
```
``` bash
# Installer Ansible dans le virtual ENV
$ make ansible
```
``` bash
# Supprimer Ansible et le VENV
$ make rm-ansible
```
``` bash
# Ajouter uniquement des utilisateurs pour tester
$ make sample
```
``` bash
# Tout déployer from scratch (construc, ansible, + recettes)
$ make deploy
```
``` bash
# Déployer une solution avec des utilisateurs (deploy + sample)
$ make demo
```
## WebUI

``` bash
# Webmail (Roundcube)
http://localhost:20080
```
``` bash
# Prometheus
http://localhost:20080
```