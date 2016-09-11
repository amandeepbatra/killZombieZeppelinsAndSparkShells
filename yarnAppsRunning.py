#!/usr/bin/python
import json
import sys
import subprocess
import os
from pprint import pprint

baseURL = "http://"+sys.argv[2]+":8088/ws/v1/cluster/apps?"
states = ["RUNNING"];
queues = ["non-production","default"];

def getQueryString(state, queue):
    finalURL = "curl "+baseURL+ "states="+state+"\&queue="+queue
    return finalURL

with open(sys.argv[1], 'w') as f:
    for state in states:
       for queue in queues:
            url =  getQueryString(state, queue)
            schedulerInfo   = subprocess.check_output(url ,shell=True)
            data = None
            data = json.loads(schedulerInfo)
            if data is not None:
                apps = data["apps"]
                if apps is not None:
                    if apps.get('app'):
                        numOfApps = len(apps.get('app'))
                        i = 0
                        while i < numOfApps:
                            appId = apps["app"][i]["id"]
                            appName =  apps["app"][i]["name"]
                            f.write("{},{}\n".format(appId,appName))
                            i += 1

