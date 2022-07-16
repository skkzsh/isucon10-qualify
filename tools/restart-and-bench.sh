#!/bin/bash
set -euvx

sudo truncate -s 0 -c /var/log/nginx/access.log
# sudo truncate -s 0 -c /var/log/nginx/error.log
sudo truncate -s 0 -c /var/log/mysql/mysql-slow.log
# sudo truncate -s 0 -c /var/log/mysql/error.log
# mysqladmin flush-logs

cd /home/isucon/isuumo/webapp/go
make
sudo systemctl restart isuumo.go

sudo systemctl restart mysql
sudo systemctl restart nginx

cd ~/isuumo/bench
./bench -target-url http://127.0.0.1 | tee ~/log/bench-$(date +%Y%m%d-%H%M%S).log

sudo cat /var/log/nginx/access.log |
alp json --sort avg -r -m '^/api/estate/[0-9]+$','^/api/estate/req_doc/[0-9]+$','^/api/chair/[0-9]+$','^/api/chair/buy/[0-9]+','^/api/recommended_estate/[0-9]+$','^/images/estate/[0-9a-f]+\.png$','^/images/chair/[0-9a-f]+\.png$' |
tee ~/log/alp-$(date +%Y%m%d-%H%M%S).log
# -q --qs-ignore-values

# sudo mysqldumpslow /var/log/mysql/mysql-slow.log | tee ~/log/slow-$(date +%Y%m%d-%H%M%S).log
# sudo pt-query-digest /var/log/mysql/mysql-slow.log | tee ~/log/pt-query-digest-$(date +%Y%m%d-%H%M%S).log

# go tool pprof -http=:10060 http://localhost:6060/debug/pprof/profile

