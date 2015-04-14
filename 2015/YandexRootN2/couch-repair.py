#!/usr/bin/env python
import datetime
import requests
import json

host = "http://127.0.0.1:5984"
headers = {'Content-type': 'application/json'}
js = requests.get("{}/words_slave/_all_docs?conflicts=true".format(host)).json()
requests.put("{}/w".format(host))
for l in js["rows"]:
   master = requests.get("{}/words/{}".format(host, l["id"])).json()
   master_ts = datetime.datetime.fromtimestamp(master["t"])
   slave = requests.get("{}/words_slave/{}".format(host, l["id"])).json()
   slave_ts = datetime.datetime.fromtimestamp(slave["t"])
   if master_ts > slave_ts:
       requests.put("{}/w/{}".format(host, l["id"]), data=json.dumps(master), headers=headers)
   else:
       requests.put("{}/w/{}".format(host, l["id"]), data=json.dumps(slave), headers=headers)
