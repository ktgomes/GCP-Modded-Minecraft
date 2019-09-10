import base64
import json
import re
import os
import googleapiclient.discovery
import mcrcon
import time

PROJECT_ID = 'PLACEHOLDER_PROJECT_ID'
PASSWORD = "PLACEHOLDER_PASSWORD"
ZONE = "us-central1-f"

"""
entrypoint for cloudfunction
and event handling
"""
def log_handler(event, context):
    print(event)
    raw_event = json.loads(base64.b64decode(event['data']).decode('utf-8'))
    raw_message = raw_event['jsonPayload']['message']

    # disconnect message
    tmp = re.findall('\]:\s\w+ left the game', raw_message)
    if len(tmp) > 0:
    	shut_it_down()
    return


"""
minecraft server interactions
"""
def execute_rcon(cmd, ip):
    # send response
    rcon = mcrcon.MCRcon(ip, PASSWORD)
    rcon.connect()
    response = rcon.command(cmd)
    rcon.disconnect()
    return response

"""
GCE interactions
"""
def lookup_instance():
    # find the minecraft vm IP
    compute = googleapiclient.discovery.build('compute', 'v1')
    instances = compute.instances().list(project=PROJECT_ID, zone=ZONE, filter="name=minecraft-vm").execute()
    return instances['items'][0]['networkInterfaces'][0]['accessConfigs'][0]['natIP']

def stop_instance():
    # find the minecraft vm IP
    compute = googleapiclient.discovery.build('compute', 'v1')
    instance_id = compute.instances().list(project=PROJECT_ID, zone=ZONE, filter="name=minecraft-vm").execute()['items'][0]['id']
    return compute.instances().stop(project=PROJECT_ID, zone=ZONE, instance='minecraft-vm').execute()

def shut_it_down():
    print('here')
    ip = lookup_instance()
    print(ip)
    resp = execute_rcon("/list", ip)
    print('it connected!')
    number = re.findall('There are (\d+) of a max \d+ players online', resp)[0]
    print(number)
    if number == "0":
        print('stopping instance')
        execute_rcon("/stop", ip)
        time.sleep(10)
        return stop_instance()
    return

if __name__ == "__main__":
    print('')
