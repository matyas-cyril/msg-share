.delete_platform: 
	@docker compose -f Docker/plateform.yml --env-file dot.env down -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to remove plateform - $?") >&2; exit 1; };
	@$(call echo_ok,"successfully delete plateform");

.purge_platform:
	@docker compose -f Docker/plateform.yml --env-file dot.env down -v --remove-orphans --rmi all \
	  || { $(call echo_err,"[ERROR] failed to purge plateform - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully purge plateform");

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

deploy_smtp: .init_dot.env .shared_folders .deploy_smtp

rm_smtp: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env ps --services \
	| grep '^smtp_postfix' \
	| xargs -r docker compose -f Docker/plateform.yml --env-file dot.env down $(service) -v --remove-orphans \
	|| { $(call echo_err,"[ERROR] failed to remove SMTP plateform - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully delete smtp container");

.deploy_dovecot:
	@docker compose -f Docker/plateform.yml --env-file dot.env up proxy-dovecot* -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker proxy Dovecot plateform") >&2; exit 1; }

rm_dovecot: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env ps --services \
	| grep '^proxy-dovecot' \
	| xargs -r docker compose -f Docker/plateform.yml --env-file dot.env down $(service) -v --remove-orphans \
	|| { $(call echo_err,"[ERROR] failed to remove proxy Dovecot plateform - $?") >&2; exit 1; }
	@$(call echo_ok,"successfully delete proxy Dovecot container");

.deploy_ldap:
	@docker compose -f Docker/plateform.yml --env-file dot.env up ldap -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker LDAP plateform") >&2; exit 1; }

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

.drop_webmail_database:
	@docker exec -i postgres psql -U messageries_root -c "DROP DATABASE IF EXISTS roundcube"

webmail: .init_dot.env .init_webmail

rm_webmail: .init_dot.env .drop_webmail_database
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

.deploy_plateform: .shared_folders .init_certif-keycloak
	@docker compose -f Docker/plateform.yml --env-file dot.env  up -d --scale keycloak=0 --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker plateform") >&2; exit 1; }

### KEYCLOAK

.init_certif-keycloak:
	@if [ ! -d "./keycloak-certs" ]; then mkdir -p ./keycloak-certs && chmod -R 755 ./keycloak-certs; fi
	@if [ ! -f "./keycloak-certs/keycloak.key" ] || [ ! -f "./keycloak-certs/keycloak.csr" ] || [ ! -f "./keycloak-certs/keycloak.crt" ]; then \
		openssl genrsa -out ./keycloak-certs/keycloak.key 2048; \
		openssl req -new -key ./keycloak-certs/keycloak.key -out ./keycloak-certs/keycloak.csr; \
		openssl x509 -req -days 36500 -in ./keycloak-certs/keycloak.csr -signkey ./keycloak-certs/keycloak.key -out ./keycloak-certs/keycloak.crt; \
	fi

.deploy_keycloak: .init_certif-keycloak
	@docker exec -i postgres psql -U messageries_root -t -c "\l" | grep -q keycloak \
	  || { docker exec -i postgres psql -U messageries_root -c "CREATE DATABASE keycloak"; }

	@docker compose -f Docker/plateform.yml --env-file dot.env up keycloak -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker keycloak plateform") >&2; exit 1; }

rm_keycloak: .init_dot.env
	@docker compose -f Docker/plateform.yml --env-file dot.env down keycloak -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to construct docker keycloak plateform") >&2; exit 1; }

# Générer des certificats pour Keycloak
certif-keycloak: .init_certif-keycloak

rm_certif-keycloak:
	@rm -rf ./keycloak-certs
