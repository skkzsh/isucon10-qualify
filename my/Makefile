SHELL := /bin/bash

NOW := $(shell date +%m%d-%H%M%S)
DATE ?= $(NOW)

ISSUE := 1

APP_NAME  := isuumo.go
APP_DIR   := ~/isuumo/webapp/go
BENCH_DIR := ~/isuumo/bench
BENCH_CMD := ./bench -target-url http://127.0.0.1
ALP_MATCH := '^/api/chair/[0-9]+','^/api/recommended_estate/[0-9]+','^/api/estate/req_doc/[0-9]+','^/api/chair/buy/[0-9]+','^/api/estate/[0-9]+' # ,'^/images/estate/[0-9a-f]+\.png$','^/images/chair/[0-9a-f]+\.png$'

ALP_OPTS ?= --limit 10000 # -q --qs-ignore-values (/api/chair/search)

NGINX_ACCESS_LOG := /var/log/nginx/access
NGINX_ERROR_LOG := /var/log/nginx/error

# DB_MIDDLE ?= mariadb
DB_MIDDLE ?= mysql
SLOW_QUERY_LOG := /var/log/mysql/$(DB_MIDDLE)-slow
MYSQL_ERROR_LOG := /var/log/mysql/error

.PHONY: rotate truncate build restart prepare bench alp slp issue

all: bench alp slp issue

rotate:
	sudo mv $(NGINX_ACCESS_LOG).log $(NGINX_ACCESS_LOG)-$(DATE).log
	sudo mv $(NGINX_ERROR_LOG).log $(NGINX_ERROR_LOG)-$(DATE).log
	sudo mv $(SLOW_QUERY_LOG).log $(SLOW_QUERY_LOG)-$(DATE).log
	sudo mv $(MYSQL_ERROR_LOG).log $(MYSQL_ERROR_LOG)-$(DATE).log

truncate:
	sudo truncate -s0 -c $(NGINX_ACCESS_LOG).log
	sudo truncate -s0 -c $(NGINX_ERROR_LOG).log
	sudo truncate -s0 -c $(SLOW_QUERY_LOG).log
	sudo truncate -s0 -c $(MYSQL_ERROR_LOG).log
    # mysqladmin flush-logs

build:
	cd $(APP_DIR) && make
	sudo systemctl restart $(APP_NAME)

restart:
	sudo systemctl restart $(DB_MIDDLE)
	sudo systemctl restart nginx
    # sudo systemctl restart memcached
	# sudo systemctl restart newrelic-infra

prepare:
	mkdir -p ~/logs

bench: prepare truncate build restart
	cd $(BENCH_DIR); \
	$(BENCH_CMD) \
	> >(tee ~/logs/bench-$(DATE).log) \
	2> >(tee ~/logs/bench-error-$(DATE).log >&2)

alp: prepare # avg, sum
	sudo alp json --file $(NGINX_ACCESS_LOG).log \
	$(ALP_OPTS) --sort sum -r \
	-m $(ALP_MATCH) | \
	tee ~/logs/alp-$(DATE).log

slp: prepare
	sudo pt-query-digest $(SLOW_QUERY_LOG).log \
	| tee ~/logs/pt-query-digest-$(DATE).log

issue:
	(cd $(APP_DIR); git rev-parse HEAD; \
	echo "\`\`\`"; cat ~/logs/bench-$(DATE).log; echo "\`\`\`"; \
	echo "<details><summary>Bench error</summary>"; echo -e "\n\`\`\`"; cat ~/logs/bench-error-$(DATE).log; echo "\`\`\`"; echo "</details>"; \
	echo "<details><summary>alp</summary>"; echo -e "\n\`\`\`"; cat ~/logs/alp-$(DATE).log; echo "\`\`\`";  echo "</details>"; \
	echo "<details><summary>NGINX error</summary>"; echo -e "\n\`\`\`"; sudo cat $(NGINX_ERROR_LOG).log; echo "\`\`\`"; echo "</details>"; \
	echo "<details><summary>MySQL error</summary>"; echo -e "\n\`\`\`"; sudo cat $(MYSQL_ERROR_LOG).log; echo "\`\`\`";  echo "</details>"; \
	) | \
	gh issue comment $(ISSUE) -F-
	# echo "<details><summary>Slow query</summary>"; echo -e "\n\`\`\`"; cat ~/logs/pt-query-digest-$(DATE).log; echo "\`\`\`";  echo "</details>"; \
