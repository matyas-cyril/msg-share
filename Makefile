
VENV_DIR=venv

# Nom du répertoire partagé
SHARED_DIR=partage

### NE PAS MODIFIER ###

SHELL=/bin/bash
PYTHON=python3
ANSIBLE_VERSION=11.10.0

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

.PHONY: install construct deploy destroy purge ansible rm-ansible sample demo

.construct_platform:
	@docker compose -f Docker/plateform.yml up -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker plateform") >&2; exit 1; }

.delete_platform:
	@docker compose -f Docker/plateform.yml down -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to remove plateform - $?") >&2; exit 1; }

.purge_platform:
	@docker compose -f Docker/plateform.yml down -v --remove-orphans --rmi all \
	  || { $(call echo_err,"[ERROR] failed to purge plateform - $?") >&2; exit 1; }

.remove_venv:
	@rm -rf $(VENV_DIR) || { $(call echo_err,"failed to remove '$(VENV_DIR)'"); exit 2; }; \
	$(call echo_ok,"successfully removed '$(VENV_DIR)'");

.init_webmail: .waiting_postgres .waiting_webmail
	@docker exec -i postgres_17.6 psql -U messageries_root -t -c "\l" | grep -q roundcube \
		|| { docker exec -i postgres_17.6 psql -U messageries_root -c "CREATE DATABASE roundcube"; }
	@docker cp roundcube_webmail:/var/www/html/SQL/postgres.initial.sql /tmp/postgres.initial.sql && \
	 docker exec -i postgres_17.6 psql -U messageries_root -d roundcube < /tmp/postgres.initial.sql;
	@rm -f /tmp/postgres.initial.sql;

.make_shared_folders:
	@mkdir -p "./$(SHARED_DIR)"/murder \
	   "./$(SHARED_DIR)"/cyrus_frontend_01 "./$(SHARED_DIR)"/cyrus_frontend_02 \
	   "./$(SHARED_DIR)"/cyrus_backend_01 "./$(SHARED_DIR)"/cyrus_backend_02 \
	   "./$(SHARED_DIR)"/cyrus_save_backend_01 "./$(SHARED_DIR)"/cyrus_save_backend_02 \
	   "./$(SHARED_DIR)"/smtp_postfix_01

.chown_shared_folders:
	@chown -R $(whoami):$(whoami) "./$(SHARED_DIR)" && chmod -R 775 "./$(SHARED_DIR)"

.remove_shared_folders:
	@rm -rf "./$(SHARED_DIR)"

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

.deploy_msg_shared:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/msg-install.yml --tags install

.waiting_postgres:
	@while ! docker exec postgres_17.6 test -S '/var/run/postgresql/.s.PGSQL.5432'; do \
		$(call echo_warn,"[WARN] waiting postgres..."); \
		sleep 1; \
	done

.waiting_webmail:
	@while ! docker exec roundcube_webmail test -f '/var/www/html/SQL/postgres.initial.sql'; do \
		$(call echo_warn,"[WARN] waiting webmail..."); \
		sleep 1; \
	done

.add_sample:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/msg-sample.yml --tags sample

# Contruire la plateforme docker + deploiement Webmail
construct: .make_shared_folders .chown_shared_folders .construct_platform .init_webmail
	@$(call echo_ok,"[INFO] deploy completed") && exit 0;

# Supprimer les containers Docker + dossiers partagés + venv
destroy: .remove_shared_folders .delete_platform
	@$(call echo_ok,"[INFO] destroy completed") && exit 0;

# Supprimer TOUTE la plateforme (containers, dossiers partagés, venv, images)
purge: .remove_shared_folders .remove_venv .purge_platform 
	@$(call echo_ok,"[INFO] purge completed") && exit 0;

# Installer ansible
ansible: .install_ansible

# Supprimer ansible
rm-ansible: .remove_venv

# Deployer une architecture from sratch sans données
deploy: construct ansible .deploy_msg_shared

# Ajouter des données pour les tests
sample: .add_sample

# Deployer une architecture + Ansible + utilisateurs pour des tests
demo: deploy sample
