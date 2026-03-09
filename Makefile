
# Version de Ansible
ANSIBLE_VERSION=10.7.0

# Dossier contenant le Virtual Env
VENV_DIR=venv

# Nom du répertoire partagé
SHARED_DIR=partage

### NE PAS MODIFIER ###
SHELL=/bin/bash
PYTHON=python3

# Seb options
GREEN=\033[32m
YELLOW=\033[33m
RED=\033[31m
RESET=\033[0m

# Fichiers makefile à inclure
-include docker.mk
-include ansible.mk

define echo_ok
	echo -e "${GREEN}$(1)${RESET}"
endef

define echo_warn
	echo -e "${YELLOW}$(1)${RESET}"
endef

define echo_err
	echo -e "${RED}$(1)${RESET}"
endef

# Charger le fichier dot.env
ifneq ("$(wildcard dot.env)","")
    include dot.env
endif

.PHONY: clean purge ansible rm_ansible murder rm_murder frontend rm_frontend backend rm_backend \
        backend-save rm_backend-save smtp rm_smtp dovecot rm_dovecot ldap rm_ldap postgres rm_postgres \
		webmail rm_webmail gestion rm_gestion adminer rm_adminer prometheus rm_prometheus \
		all demo keycloak rm_keycloak certif-keycloak rm_certif-keycloak

# Supprimer les containers Docker + dossiers partagés + venv
clean: .init_dot.env .delete_platform .remove_shared_folders .remove_venv

# Supprimer TOUTE la plateforme (containers, dossiers partagés, venv, images)
purge: .init_dot.env .purge_platform .remove_shared_folders .remove_venv

# Déployer et installer LDAP, Dovecot, Webmail, Adminer, Keycloak... sauf tout ce qui est messagerie
all: .init_dot.env .deploy_plateform .install_plateform .install_msg_shared .init_webmail .init_keycloak
	@$(call echo_ok,"[INFO] deploy completed") && exit 0;

.init_dot.env:
	@if [ ! -f "dot.env" ]; then touch dot.env; fi
	@if [ -d "./sources" ] && [ -n "$(COPY_SRC_CMD)" ] && [ -n "$(COPY_GPG_CMD)" ]; then \
		for dir in Cyrus Gestion Postfix Proxy-Dovecot; do \
			cp -rf ./sources/ "./Docker/$$dir/sources"; \
			sed -e "s|\#\ \%COPY_GPG_CMD\%|$(COPY_GPG_CMD)|g" ./Docker/$$dir/Dockerfile.template | sed -e "s|\#\ \%COPY_SRC_CMD\%|$(COPY_SRC_CMD)|g" - > "./Docker/$$dir/Dockerfile"; \
		done \
	else \
		for dir in Cyrus Gestion Postfix Proxy-Dovecot; do \
			sed "\|\#\ \%COPY_GPG_CMD\%|d" ./Docker/$$dir/Dockerfile.template | sed "\|\#\ \%COPY_SRC_CMD\%|d" - > "./Docker/$$dir/Dockerfile"; \
			rm -rf "./Docker/$$dir/sources"; \
		done \
	fi

.make_shared_folders:
	@mkdir -p "./$(SHARED_DIR)"/murder \
	   "./$(SHARED_DIR)"/cyrus_frontend_01 "./$(SHARED_DIR)"/cyrus_frontend_02 \
	   "./$(SHARED_DIR)"/cyrus_backend_01 "./$(SHARED_DIR)"/cyrus_backend_02 \
	   "./$(SHARED_DIR)"/cyrus_save_backend_01 "./$(SHARED_DIR)"/cyrus_save_backend_02 \
	   "./$(SHARED_DIR)"/smtp_postfix_01

.chown_shared_folders:
	@chown -R $(whoami):$(whoami) "./$(SHARED_DIR)" && chmod -R 775 "./$(SHARED_DIR)"

.shared_folders: .make_shared_folders .chown_shared_folders

.remove_shared_folders:
	@rm -rf "./$(SHARED_DIR)";
	@$(call echo_ok,"successfully removed shared folders");

.install_plateform: .install_ansible .configure_ldap .install_dovecot
