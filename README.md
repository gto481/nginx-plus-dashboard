# nginx-plus-dashboard
NAP Security Log, Metric and Access Log Dashboard



## Deployment

To deploy this project run

```bash
On Grafana Host
1. Follow https://github.com/skenderidis/nap-dashboard
2. cd ~/nginx-plus-dashboard/grafana-host
2. docker run -dit -p 9090:9090 -v ~/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus

On Grafana dashboard
1. Import ~/nginx-plus-dashboard/grafana-host/grafana_dashboard_json/nginx_plus_metric_dashboard.json
2. Import ~/nginx-plus-dashboard/grafana-host/grafana_dashboard_json/nginx_plus_access_log_dashboard.json



On Nginx Host
***NGINX NAP need to be installed prior the following steps
modules***

1. Copy nap_log_profile.json_dashboard.tgz to /etc/app_protect/bundles
2. Copy policy-demo.tgz to /etc/app_protect/bundles
3. sudo chown -R 101:101 /etc/app_protect/bundles
4. Copy nginx.conf to /etc/nginx
5. Copy default.conf to /etc/nginx/conf.d
6. Copy httplb.conf to /etc/nginx/conf.d
7. Copy nginx-plus-mgmt.conf to /etc/nginx/conf.d
8. sudo apt install nginx-plus-module-prometheus
9. cd ~/nginx-plus-dashboard/nginx-host/loki-promtail
10. docker compose up -d
11. sudo systemctl start nginx

```

## Import Dashboard Menu on Grafana

![Dashboard Import](images/dashboard-import.jpg)

