#!/usr/bin/env bash

# create the minecraft instance and open firewall rules
echo "[*] create compute instance and firewall rules"
gcloud deployment-manager deployments create mc --config instance.yml

# Copy local docker file to instance
gcloud compute scp Dockerfile minecraft-vm:/home/o0sirensong0o/

# retrieve the server IP
echo "[*] done..."
IP=$(gcloud compute instances describe minecraft-vm --zone us-central1-f | grep natIP | cut -d\: -f2)
echo
echo "Minecraft Server IP: $IP"
echo
