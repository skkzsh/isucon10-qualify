#!/bin/bash
set -euvx

sudo truncate -s 0 -c /var/log/nginx/access.log
sudo truncate -s 0 -c /var/log/mysql/slow.log
# mysqladmin flush-logs

cd /home/isucon/isuumo/webapp/go
make
sudo systemctl restart isuumo.go

sudo systemctl restart mysql
sudo systemctl restart nginx

cd ~/isuumo/bench
./bench -target-url http://127.0.0.1

sudo cat /var/log/nginx/access.log | \
	alp json --sort avg -r -m '^/api/estate/[0-9]+$','^/api/estate/req_doc/[0-9]+$','^/api/chair/[0-9]+$','^/api/chair/buy/[0-9]+','^/api/recommended_estate/[0-9]+$','^/images/estate/[0-9a-f]+\.png$','^/images/chair/[0-9a-f]+\.png$'

# sudo mysqldumpslow /var/log/mysql/slow.log
# sudo pt-query-digest /var/log/mysql/slow.log

# go tool pprof -http=:10060 http://localhost:6060/debug/pprof/profile

