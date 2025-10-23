
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

.PHONY: all clean purge \
        postgres rm_postgres webmail rm_webmail ansible rm_ansible ldap rm_ldap \
        murder rm_murder frontend rm_frontend backend rm_backend backend-save rm_backend-save \
		smtp rm_smtp

all: .init_dot.env

# Supprimer les containers Docker + dossiers partagés + venv
clean: .init_dot.env .delete_platform .remove_shared_folders .remove_venv

# Supprimer TOUTE la plateforme (containers, dossiers partagés, venv, images)
purge: .init_dot.env .purge_platform .remove_shared_folders .remove_venv

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

.delete_platform: 
	@docker compose -f Docker/plateform.yml --env-file dot.env down -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to remove plateform - $?") >&2; exit 1; };
	@$(call echo_ok,"successfully delete plateform");

.purge_platform:
	@docker compose -f Docker/plateform.yml --env-file dot.env down -v --remove-orphans --rmi all \
	  || { $(call echo_err,"[ERROR] failed to purge plateform - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully purge plateform");

.make_venv:
	@if [ ! -d $(VENV_DIR) ] || [ ! -f $(VENV_DIR)/bin/activate ]; then \
		$(PYTHON) -m venv $(VENV_DIR) \
			|| { $(call echo_err,"virtual environment failed in '$(VENV_DIR)'"); exit 2; }; \
		$(call echo_ok,"virtual environment created in '$(VENV_DIR)'"); \
	else \
		$(call echo_ok,"virtual environment '$(VENV_DIR)' already exist"); \
	fi

.install_ansible: .make_venv
	@$(call echo_ok,"starting install of Ansible $(ANSIBLE_VERSION)");
	@$(VENV_DIR)/bin/pip3 install ansible==$(ANSIBLE_VERSION) \
		|| { $(call echo_err,"ansible installation failed"); exit 2; }; \
	$(call echo_ok,"successfully installed Ansible $(ANSIBLE_VERSION)");

.remove_venv:
	@rm -rf $(VENV_DIR) || { $(call echo_err,"failed to remove '$(VENV_DIR)'"); exit 2; }; \
	$(call echo_ok,"successfully removed '$(VENV_DIR)'");

ansible: .init_dot.env .install_ansible

rm_ansible: .init_dot.env .remove_venv

.deploy_msg_murder:
	@docker compose -f Docker/plateform.yml --env-file dot.env up murder -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker Cyrus Murder plateform") >&2; exit 1; }

murder: .init_dot.env .shared_folders .deploy_msg_murder

rm_murder: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env down murder -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to remove Cyrus Murder - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully delete murder container");

.deploy_msg_frontend:
	@docker compose -f Docker/plateform.yml --env-file dot.env up frontend_* -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker Cyrus Frontend plateform") >&2; exit 1; }

frontend: .init_dot.env .shared_folders .deploy_msg_frontend

rm_frontend: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env ps --services \
	| grep '^frontend_' \
	| xargs -r docker compose -f Docker/plateform.yml --env-file dot.env down $(service) -v --remove-orphans \
	|| { $(call echo_err,"[ERROR] failed to remove Cyrus Frontend - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully delete frontend container");

.deploy_msg_backend:
	@docker compose -f Docker/plateform.yml --env-file dot.env up backend_* -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker Cyrus Backend plateform") >&2; exit 1; }

backend: .init_dot.env  .shared_folders .deploy_msg_backend

rm_backend: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env ps --services \
	| grep '^backend_' \
	| xargs -r docker compose -f Docker/plateform.yml --env-file dot.env down $(service) -v --remove-orphans \
	|| { $(call echo_err,"[ERROR] failed to remove Cyrus Backend - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully delete backend container");

.deploy_msg_backend_save:
	@docker compose -f Docker/plateform.yml --env-file dot.env up save_backend_* -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker Cyrus Save Backend plateform") >&2; exit 1; }

backend-save: .init_dot.env .shared_folders .deploy_msg_backend_save

rm_backend-save: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env ps --services \
	| grep '^save_backend_' \
	| xargs -r docker compose -f Docker/plateform.yml --env-file dot.env down $(service) -v --remove-orphans \
	|| { $(call echo_err,"[ERROR] failed to remove Cyrus Save Backend - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully delete save backend container");

.deploy_smtp:
	@docker compose -f Docker/plateform.yml --env-file dot.env up smtp_postfix* -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker SMTP plateform") >&2; exit 1; }

smtp: .init_dot.env .shared_folders .deploy_smtp

rm_smtp: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env ps --services \
	| grep '^smtp_postfix' \
	| xargs -r docker compose -f Docker/plateform.yml --env-file dot.env down $(service) -v --remove-orphans \
	|| { $(call echo_err,"[ERROR] failed to remove SMTP plateform - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully delete smtp container");

.deploy_dovecot:
	@docker compose -f Docker/plateform.yml --env-file dot.env up proxy-dovecot* -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker proxy Dovecot plateform") >&2; exit 1; }

.install_dovecot:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/proxy-dovecot.yml --tags install

dovecot: .init_dot.env .shared_folders .deploy_dovecot .install_dovecot

rm_dovecot: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env ps --services \
	| grep '^proxy-dovecot' \
	| xargs -r docker compose -f Docker/plateform.yml --env-file dot.env down $(service) -v --remove-orphans \
	|| { $(call echo_err,"[ERROR] failed to remove proxy Dovecot plateform - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully delete proxy Dovecot container");

.deploy_ldap:
	@docker compose -f Docker/plateform.yml --env-file dot.env up ldap -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker LDAP plateform") >&2; exit 1; }

.configure_ldap:
	@$(call echo_ok,"[INFO] add samples data to ldap...")
	@ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/ldap-install.yml --tags install \
	   || { $(call echo_err,"[ERROR] failed to deploy ansible") >&2; exit 1; }

ldap: .init_dot.env .deploy_ldap .configure_ldap

rm_ldap: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env down ldap -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to remove ldap - $?") >&2; exit 1; }

.deploy_postgres:
	@docker compose -f Docker/plateform.yml --env-file dot.env up postgres -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker postgres") >&2; exit 1; }

.waiting_postgres:
	@cpt=0; \
	while ! docker exec postgres test -S '/var/run/postgresql/.s.PGSQL.5432'; do \
        if [ $$cpt -ge 10 ]; then \
            $(call echo_err,"[ERROR] PostgreSQL did not start in time"); \
            exit 1; \
        fi; \
		$(call echo_warn,"[WARN] waiting postgres..."); \
		sleep 1; \
		cpt=$$((cpt+1)); \
	done

postgres: .init_dot.env .deploy_postgres

rm_postgres: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env down postgres -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to remove postgres - $?") >&2; exit 1; }

.deploy_webmail:
	@docker compose -f Docker/plateform.yml --env-file dot.env up roundcube -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker webmail") >&2; exit 1; }

.waiting_webmail:
	@cpt=0; \
	while ! docker exec roundcube_webmail test -f '/var/www/html/SQL/postgres.initial.sql'; do \
        if [ $$cpt -ge 15 ]; then \
            $(call echo_err,"[ERROR] Webmail did not start in time"); \
            exit 1; \
        fi; \
		$(call echo_warn,"[WARN] waiting webmail..."); \
		sleep 1; \
		cpt=$$((cpt+1)); \
	done

.init_webmail: .waiting_postgres .deploy_webmail .waiting_webmail
	@docker exec -i postgres psql -U messageries_root -t -c "\l" | grep -q roundcube \
		|| { docker exec -i postgres psql -U messageries_root -c "CREATE DATABASE roundcube"; }
	@docker cp roundcube_webmail:/var/www/html/SQL/postgres.initial.sql /tmp/postgres.initial.sql && \
	 docker exec -i postgres psql -U messageries_root -d roundcube < /tmp/postgres.initial.sql;
	@rm -f /tmp/postgres.initial.sql;

webmail: .init_dot.env .init_webmail

rm_webmail: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env down roundcube -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to remove roundcube - $?") >&2; exit 1; }

.deploy_gestion:
	@docker compose -f Docker/plateform.yml --env-file dot.env up gestion* -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker gestion plateform") >&2; exit 1; }

gestion: .init_dot.env .shared_folders .deploy_gestion

rm_gestion: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env ps --services \
	| grep '^gestion' \
	| xargs -r docker compose -f Docker/plateform.yml --env-file dot.env down $(service) -v --remove-orphans \
	|| { $(call echo_err,"[ERROR] failed to remove gestion plateform - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully delete gestion container");

adminer: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env up adminer -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker adminer plateform") >&2; exit 1; }

rm_adminer: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env down adminer -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker adminer plateform") >&2; exit 1; }

prometheus: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env up prometheus -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker prometheus plateform") >&2; exit 1; }

rm_prometheus: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env down prometheus -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker prometheus plateform") >&2; exit 1; }

.deploy_plateform: .shared_folders
	@docker compose -f Docker/plateform.yml --env-file dot.env up -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker plateform") >&2; exit 1; }

.install_plateform: .install_ansible .configure_ldap .install_dovecot

# Déployer et installer LDAP, Dovecot, Webmail, Adminer, Keycloak... sauf tout ce qui est messagerie
deploy: .init_dot.env .deploy_plateform .install_plateform .init_webmail
	@$(call echo_ok,"[INFO] deploy completed") && exit 0;

.install_msg_shared:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/msg-install.yml --tags install

install: .init_dot.env .deploy_plateform .install_plateform .install_msg_shared

.add_msg_sample:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/msg-sample.yml --tags sample

.add_login_sample:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/proxy-dovecot.yml --tags sample

demo: install .add_msg_sample .add_login_sample