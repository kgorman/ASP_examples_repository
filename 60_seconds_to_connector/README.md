
# 60 Seconds to MongoDB Atlas Stream Processing

This is an example session of creating a Kafka connector in Atlas Stream Processing using the
Atlas Administrative API.

## Prerequisites
1. The Atlas CLI installed. [Install docs are here](https://www.mongodb.com/docs/atlas/api/atlas-admin-api/). You may already have it installed, you can test by running `atlas help` on the command line.  
2. The mongosh utility version 2.0 or above installed. [Install docs are here](https://www.mongodb.com/docs/mongodb-shell/install/).
3. git and GitHub. The ability to clone from github.

## 1. Clone this repo
The first step is to clone this repo so you have examples for all of the files on disk.
```bash
$ git clone https://github.com/kgorman/ASP_examples_repository.git
$ cd ASP_examples_repository/60_seconds_to_connector
```

## 2. Configure the environment for Atlas Stream Processing
To create a processor that works just like a connector, follow this example, you can copy and paste each command line (without the $ sign) to your terminal, and compare the output against this example. For this example we will connect MongoDB as a source (reading a change stream) and Kafka as the sink (data is pushed to Kafka).

### Authenticate to MongoDB Atlas
```bash
# connect to the Atlas Admin API. A window will pop up for you to authenticate
$ atlas auth login
$ atlas auth whoami 
Logged in as yourname@you.com
```

### Create an instance
Create a Stream Processing Instance named `ASPConnector` to run your connector on. Billing only happens when the processor is running. This example will cost about $0.19/hr to run (for up to 4 processors). So about $0.05/hr for a single connector. The instance will be created on AWS in US-EAST using the SP10 instance type.

```bash
# create an instance to run the stream processor. 
$ atlas streams instances create ASPConnector --region VIRGINIA_USA --tier SP10 --provider AWS
Atlas Streams Processor Instance 'ASPConnector' successfully created.
```

### Create the source and sink connections
Create the source and sink connections in the MongoDB Atlas Stream Processing Connection Registry. These entries can then be referred to by canonical name in our stream processor.

The source connector configuration is saved in the file named `c_mongodb.json`, open that file and change the `clusterName` to the name of the cluster you will be reading changes from. This must be in the same project you are connected to using `atlas auth login`. You can list the clusters within the project using `atlas cluster list`.  If you do not have a cllsuter available, create one before proceeding. Note that Atlas Stream Processing does not define a connection as a source or a sink, a connection once defined can seamlessly be used in both scenarios.

Once that change is complete, create the source in the Connection Registry for our test instance.

```bash
# create a source connection in the connection registry for MongoDB
$ atlas streams connections create -f c_mongodb.json -i ASPConnector -o json
{
  "name": "TestConnectorSource",
  "type": "Cluster",
  "clusterName": "StreamSourceDB",
  "dbRoleToExecute": {
    "role": "readWriteAnyDatabase",
    "type": "BUILT_IN"
  }
}
```
The sink configuration is saved in a file named `c_kafka.json`. Changes for each source collection will be written to a Kafka topic with the same name. So for this example collection names must be unique. Open the file and change the values for `mechanism`, `username`, `password` and `protocol` to match your Kafka cluster credentials and authentication type.

```bash
# Create a sink connection in the connection registry for Kafka
$ atlas streams connections create -f c_kafka.json -i ASPConnector -o json
{
  "name": "TestConnectorSink",
  "type": "Kafka",
  "authentication": {
    "mechanism": "SCRAM-256",
    "username": "mongo"
  },
  "bootstrapServers": "kafka.xxx.yyy.com:9093",
  "networking": {
    "access": {
      "type": "PUBLIC"
    }
  },
  "security": {
    "protocol": "SASL_PLAINTEXT"
  }
}
```
### Getting the connection string for the instance

```bash
# Get a connection string from our instance, and use that to start mongosh
$ atlas streams instance describe ASPConnector -o json
{
  "_id": "66e07c1d7954bd1e9e18d042",
  "dataProcessRegion": {
    "cloudProvider": "AWS",
    "region": "VIRGINIA_USA"
  },
  "groupId": "65094f059e0776665611598b",
  "hostnames": [ 
    # this is the connection string
    "atlas-stream-xxx.yyy.zzz.mongodb.net"  
  ],
  "name": "ASPConnector",
  "streamConfig": {
    "tier": "SP10"
  }
}
```

## 3. Create and run a connector using Atlas Stream Processing
Use the output from the previous command for the `hostnames` array at element 0, and set that as the connection string for connecting via mongosh. You will need to set your DB username as well.

When mongosh is run it will start the stream processor according to the pipeline defined in `connector.js` and name it `connector01`. It will start moving data from source to sink. Once run, you should now see database changes being propagated over into kafka topics, one topic per collection name!

```bash
# connect via mongosh and run the stream processor
$ SPI = "mongodb://atlas-stream-xxx.yyy.zzz.mongodb.net"
$ USERNAME = "myDBusername"

$ mongosh $SPI --tls --authenticationDatabase admin --username $USERNAME ./connector.js
```

If you want to manage the running stream processor, connect to the SPI using mongosh as we did above and explore your stream processor!

- List the statistics of the running stream processor: `sp.connector01.stats()`
- Stop the stream processor: `sp.connector01.stop()`
- Start the stream processor: `sp.connector01.start()`