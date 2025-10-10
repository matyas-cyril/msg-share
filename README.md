# msg-share

## Dépendances
```
$ sudo apt install make docker-ce docker-ce-cli containerd.io python3-venv 
```
## Commandes

``` bash
# Déployer une plateforme de messagerie (Docker)
$ make deploy
```
``` bash
# Supprimer la plateforme de messagerie 
$ make destroy
```
``` bash
# Installer les recettes Ansible
$ make install
```
``` bash
# Ajouter des utilisateurs pour tester
$ make sample
```
``` bash
# Tout déployer from scratch (deploy, install, demo)
$ make demo
```