# nginx-plus-dashboard
NAP Security Log, Metric and Access Log Dashboard



## Deployment

To deploy this project run

```bash
On Grafana Host
1. Follow https://github.com/skenderidis/nap-dashboard

On Nginx Host
***NGINX NAP need to be installed prior the following steps

1. Copy nap_log_profile.json_dashboard.tgz to /etc/app_protect/bundles
2. Copy policy-demo.tgz to /etc/app_protect/bundles
3. sudo chown -R 101:101 /etc/app_protect/bundles
4. Copy nginx.conf to /etc/nginx
5. Copy default.conf to /etc/nginx/conf.d
6. Copy httplb.conf to /etc/nginx/conf.d
7. Copy nginx-plus-mgmt.conf to /etc/nginx/conf.d
8. Run sudo systemctl start nginx

```


