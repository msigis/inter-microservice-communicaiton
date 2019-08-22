import ballerina/http;
import ballerina/log;
import ballerina/jms;

type Person record {
    string name;
    string address;
    string phonenumber;
    string registerID;
    string email;
};

listener http:Listener httpListener = new(9091);

// Initialize a JMS connection with the provider
// 'Apache ActiveMQ' has been used as the message broker
jms:Connection conn = new({
        initialContextFactory: "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
        providerUrl: "tcp://localhost:61616"
    });

// Initialize a JMS session on top of the created connection
jms:Session jmsSession = new(conn, {
        // Optional property. Defaults to AUTO_ACKNOWLEDGE
        acknowledgementMode: "AUTO_ACKNOWLEDGE"
    });

// Initialize a queue receiver using the created session
listener jms:QueueReceiver jmsConsumer = new(jmsSession, queueName = "trip-driver-notify");

// JMS service that consumes messages from the JMS queue
// Bind the created consumer to the listener service
service DriverNotificationService on jmsConsumer {
    // Triggered whenever an order is added to the 'OrderQueue'
    resource function onMessage(jms:QueueReceiverCaller consumer, jms:Message message) returns error? {
        log:printInfo("Trip information received for Driver notification service notifying coordinating with Driver the trip info");
        http:Request orderToDeliver = new;
        // Retrieve the string payload using native function
        string personDetail = check message.getTextMessageContent();
        log:printInfo("Trip Details: " + personDetail);
        return;
    }   
}