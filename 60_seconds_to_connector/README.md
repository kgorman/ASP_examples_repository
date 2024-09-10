
60 Seconds to MongoDB Atlas Stream Processing
==============

This is an example session of creating a Kafka connector in Atlas Stream Processing using the
Atlas Administrative API. 


```bash

# Prerequisites are a MongoDB Atlas account and Atlas Admin API configured.
# extra points for having the JSON utility jq installed, but not required.

# Connect to the Atlas Admin API. A window will pop up for you to authenticate
$atlas auth login
$atlas auth whoami 
Logged in as kenny.gorman@mongodb.com

# create an instance to run the stream processor. Note: that billing only
# happens when running the processor. This test will cost about $0.20.
# create the instance on AWS in US-EAST using the SP10 instance type.
$atlas streams instances create KennyViaAPI2 --region VIRGINIA_USA --tier SP10 --provider AWS
Atlas Streams Processor Instance 'KennyViaAPI2' successfully created.

# List the instance and return the connect string. Note I am using jq to
# make the output compact, but you don't have to.
$atlas streams instance describe KennyViaAPI2 -o json | jq -c .hostnames   
["xxxxyyyyyy.mongodb.net"]

# now use that output to connect via Mongosh.
$mongosh "mongodb://xxxxyyyyyy.mongodb.net" --tls --authenticationDatabase admin --username kgorman
Enter password: ****************

AtlasStreamProcessing> 

# Run a simple stream processor from the sample stream solar source.
AtlasStreamProcessing>sp.process([{$source:{connectionName:"sample_stream_solar"}}]);

# data will spool back from the sample streaming source!
{
  device_id: 'device_1',
  group_id: 2,
  timestamp: '2024-09-05T23:15:01.585+00:00',
  max_watts: 450,
  event_type: 0,
  obs: {
    watts: 218,
    temp: 14
  },
  _ts: ISODate("2024-09-05T23:15:01.585Z"),
  _stream_meta: {
    source: {
      type: 'generated'
    }
  }
}
```