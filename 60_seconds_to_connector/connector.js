
// Create a source stage. In this case, the data is a simple document array
let source = {
  $source: { connectionName: "TestConnectorSource" },
};

// Create a emit stage and notice the variable substitutions for topic using
// The collection name as the topic 
let sink = {
  $emit: { connectionName: "TestConnectorSink", topic: "$ns.coll" },
};

// Assemble the processor, name it, and start it.
let processor = [ source, sink ]
sp.createStreamProcessor('connector01', processor)
sp.connector01.start();
