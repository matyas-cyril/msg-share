### Installer plateforme
.install_msg_shared:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/msg-install.yml --tags install
#####

### Ansible
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
#####

### LDAP 
.configure_ldap:
	@$(call echo_ok,"[INFO] add samples data to ldap...")
	@ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/ldap-install.yml --tags install \
	   || { $(call echo_err,"[ERROR] failed to deploy ansible") >&2; exit 1; }

ldap: .init_dot.env .deploy_ldap .configure_ldap
#####

### Dovecot
.install_dovecot:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/proxy-dovecot.yml --tags install

dovecot: .init_dot.env .shared_folders .deploy_dovecot .install_dovecot
#####

### Keycloak
.configure_keycloak:
	@$(call echo_ok,"[INFO] configuring keycloak...")
	@ANSIBLE_CONFIG=Ansible/ansible.cfg \
	  $(VENV_DIR)/bin/ansible-playbook Ansible/keycloak-install.yml --tags install \
	  || { $(call echo_err,"[ERROR] failed to deploy keycloak ansible") >&2; exit 1; }

.init_keycloak: .waiting_postgres .deploy_keycloak .configure_keycloak

keycloak: .init_dot.env .init_keycloak 
	@$(call echo_ok,"[INFO] keycloak deployment completed") && exit 0;
#####

### Ajouter des tests
.add_msg_sample:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/msg-sample.yml --tags sample

.add_login_sample:
	ANSIBLE_CONFIG=Ansible/ansible.cfg \
	   $(VENV_DIR)/bin/ansible-playbook Ansible/proxy-dovecot.yml --tags sample

demo: all .add_msg_sample .add_login_sample
	@$(call echo_ok,"[INFO] mode demo deployment completed") && exit 0;
#####