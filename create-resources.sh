#!/usr/bin/env bash

# create the minecraft instance and open firewall rules
echo "[*] create compute instance and firewall rules"
gcloud deployment-manager deployments create mc --config instance.yml

# retrieve the server IP
echo "[*] done..."
IP=$(gcloud compute instances describe minecraft-vm --zone us-central1-f | grep natIP | cut -d\: -f2)
echo
echo "Minecraft Server IP: $IP"
echo
