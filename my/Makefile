DATE := $(shell date +%m%d-%H%M%S)

ISSUE := 1

APP_NAME  := isuumo.go
APP_DIR   := ~/isuumo/webapp/go
BENCH_DIR := ~/isuumo/bench
BENCH_CMD := ./bench -target-url http://127.0.0.1
ALP_MATCH := '^/api/estate/[0-9]+$','^/api/estate/req_doc/[0-9]+$','^/api/chair/[0-9]+$','^/api/chair/buy/[0-9]+','^/api/recommended_estate/[0-9]+$','^/images/estate/[0-9a-f]+\.png$','^/images/chair/[0-9a-f]+\.png$' |

ALP_OPTS ?= -q # --qs-ignore-values

NGINX_ACCESS_LOG := /var/log/nginx/access

# DB_MIDDLE ?= mariadb
DB_MIDDLE ?= mysql
SLOW_QUERY_LOG := /var/log/mysql/$(DB_MIDDLE)-slow

.PHONY: rotate truncate build restart prepare bench alp slp

all: bench alp slp issue

rotate:
	sudo mv $(NGINX_ACCESS_LOG).log $(NGINX_ACCESS_LOG)-$(DATE).log
	# sudo mv /var/log/nginx/error.log /var/log/nginx/error-$(DATE).log
	sudo mv $(SLOW_QUERY_LOG).log $(SLOW_QUERY_LOG)-$(DATE).log
	# sudo mv /var/log/mysql/error.log /var/log/mysql/error-$(DATE).log

truncate:
	sudo truncate -s0 -c $(NGINX_ACCESS_LOG).log
	# sudo truncate -s0 -c /var/log/nginx/error.log
	sudo truncate -s0 -c $(SLOW_QUERY_LOG).log
	# sudo truncate -s0 -c /var/log/mysql/error.log
    # mysqladmin flush-logs

build:
	cd $(APP_DIR) && make
	sudo systemctl restart $(APP_NAME)

restart:
	sudo systemctl restart $(DB_MIDDLE)
	sudo systemctl restart nginx
    # sudo systemctl restart memcached

prepare:
	mkdir -p ~/logs

bench: prepare # truncate build restart
	cd $(BENCH_DIR); \
	$(BENCH_CMD) 2>&1 | \
	tee ~/logs/bench-$(DATE).log

alp: prepare
	sudo alp json --file $(NGINX_ACCESS_LOG).log \
	$(ALP_OPTS) --sort avg -r \ # avg, sum
	-m $(ALP_MATCH) | \
	tee ~/logs/alp-$(DATE).log

slp: prepare
	sudo pt-query-digest $(SLOW_QUERY_LOG).log \
	| tee ~/logs/pt-query-digest-$(DATE).log

issue: bench # alp slp
	(cd $(APP_DIR); git rev-parse HEAD; cat ~/logs/bench-$(DATE).log) | \
	gh issue comment $(ISSUE) -F- # ~/logs/alp-$(DATE).log ~/logs/pt-query-digest-$(DATE).log
