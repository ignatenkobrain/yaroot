mkdir /var/log/couchdb
chown couchdb:couchdb /var/log/couchdb
systemctl start couchdb
./couch-repair.py
systemctl stop couchdb
cd /var/lib/couchdb/
mv w.couch words.couch
rm words_slave.couch -f
systemctl start couchdb
export HOST="http://127.0.0.1:5984"
curl -X PUT $HOST/words_slave
curl -H "Content-Type: application/json" \
     -X POST $HOST/_replicate \
     -d '{"source":"words","target":"http://127.0.0.1:5984/words_slave"}'
