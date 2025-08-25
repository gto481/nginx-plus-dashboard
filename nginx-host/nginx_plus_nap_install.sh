#!/bin/bash

#Install NGINX Plus

# Path to your NGINX Plus repo cert/key (download from your F5/NGINX customer portal)
NGINX_CERT="/home/ubuntu/nginx-repo.crt"
NGINX_KEY="/home/ubuntu/nginx-repo.key"
NGINX_LICENSE="/home/ubuntu/license.jwt"

# =============================================================================
# PRECHECKS
# =============================================================================
if [[ ! -f "$NGINX_CERT" || ! -f "$NGINX_KEY" ]]; then
  echo "Missing NGINX Plus repository cert/key:"
  echo "   $NGINX_CERT"
  echo "   $NGINX_KEY"
  echo "   Place your files there before running."
  exit 1
fi

sudo mkdir -p /etc/ssl/nginx
sudo cp "$NGINX_CERT" /etc/ssl/nginx/
sudo cp "$NGINX_KEY"  /etc/ssl/nginx/
sudo apt update
sudo apt install -y apt-transport-https lsb-release ca-certificates wget gnupg2 ubuntu-keyring
wget -qO - https://cs.nginx.com/static/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/plus/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-plus.list
sudo wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx
sudo apt update
sudo apt install -y nginx-plus
sudo cp "$NGINX_LICENSE"  /etc/nginx/

#Install NGINX NAP

sudo systemctl restart nginx
printf "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] https://pkgs.nginx.com/app-protect-x-plus/ubuntu `lsb_release -cs` nginx-plus\n" | sudo tee /etc/apt/sources.list.d/nginx-app-protect.list

sudo apt-get update
sudo apt-get install -y app-protect-module-plus

sudo mkdir -p /opt/app_protect/config /opt/app_protect/bd_config /etc/app_protect/bundles
sudo chown -R 101:101 /opt/app_protect/
sudo chown -R 101:101 /etc/app_protect/bundles

sudo mkdir -p /etc/docker/certs.d/private-registry.nginx.com
sudo cp "$NGINX_CERT" /etc/docker/certs.d/private-registry.nginx.com/client.cert
sudo cp "$NGINX_KEY" /etc/docker/certs.d/private-registry.nginx.com/client.key

sudo apt install nginx-plus-module-geoip2
sudo apt install nginx-plus-module-prometheus

cat <<EOF >>docker-compose.yml
services:
  waf-enforcer:
    container_name: waf-enforcer
    image: private-registry.nginx.com/nap/waf-enforcer:5.2.0
    environment:
      - ENFORCER_PORT=50000
    ports:
      - "50000:50000"
    volumes:
      - /opt/app_protect/bd_config:/opt/app_protect/bd_config
    networks:
      - waf_network
    restart: always

  waf-config-mgr:
    container_name: waf-config-mgr
    image: private-registry.nginx.com/nap/waf-config-mgr:5.2.0
    volumes:
      - /opt/app_protect/bd_config:/opt/app_protect/bd_config
      - /opt/app_protect/config:/opt/app_protect/config
      - /etc/app_protect/conf:/etc/app_protect/conf
      - /etc/app_protect/bundles:/etc/app_protect/bundles
    restart: always
    network_mode: none
    depends_on:
      waf-enforcer:
        condition: service_started

networks:
  waf_network:
    driver: bridge
EOF

sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce
sudo usermod -aG docker ${USER}

sudo docker compose up -d
sudo systemctl restart nginx
