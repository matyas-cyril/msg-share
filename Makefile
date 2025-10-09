
SHELL=/bin/bash

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

.PHONY: deploy destroy

.delete_docker:
	@docker compose -f Docker/plateform.yml down -v --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to remove docker plateform - $?") >&2; exit 1; }

.deploy_docker:
	@docker compose -f Docker/plateform.yml up -d --remove-orphans \
	  || { $(call echo_err,"[ERROR] failed to deploy docker plateform") >&2; exit 1; } 

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

.init_webmail: .waiting_postgres .waiting_webmail
	@docker exec -i postgres_17.6 psql -U messageries_root -t -c "\l" | grep -q roundcube \
		|| { docker exec -i postgres_17.6 psql -U messageries_root -c "CREATE DATABASE roundcube"; }
	@docker cp roundcube_webmail:/var/www/html/SQL/postgres.initial.sql /tmp/postgres.initial.sql && \
	 docker exec -i postgres_17.6 psql -U messageries_root -d roundcube < /tmp/postgres.initial.sql;
	@rm -f /tmp/postgres.initial.sql;

deploy: .deploy_docker .init_webmail
	@$(call echo_ok,"[INFO] deploy completed") && exit 0;

destroy: .delete_docker
	@$(call echo_ok,"[INFO] destroy completed") && exit 0;

