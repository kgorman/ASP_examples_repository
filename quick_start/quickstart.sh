#!/bin/bash

atlas auth login
atlas streams instances create ASPTEST --region VIRGINIA_USA --tier SP10 --provider AWS
echo '{ "name": "sample_stream_solar", "type": "Sample" }' > mongo_sample.json 
atlas streams connections create -f mongo_sample.json -i ASPTEST -o json
atlas accessLists create --currentIp
atlas dbusers create readWriteAnyDatabase -u asptestuser -p justatestpasswordchangemelater
echo 'sp.process([{ $source: { connectionName: "sample_stream_solar" } }]);' | mongosh $(atlas streams instance describe ASPTEST -o json |  grep 'query.mongodb.net' | sed 's/"//g') --tls --authenticationDatabase admin -u asptestuser -p justatestpasswordchangemelater 