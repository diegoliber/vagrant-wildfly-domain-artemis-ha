package com.github.diegoliber.spring.messaging.wildfly;

import java.util.Properties;

import javax.jms.ConnectionFactory;
import javax.jms.Destination;
import javax.jms.JMSConsumer;
import javax.jms.JMSContext;
import javax.jms.JMSException;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

class JMSTest {

    private static final Logger log = LoggerFactory.getLogger(JMSTest.class.getName());

    // Set up all the default values
    private static final String DEFAULT_MESSAGE = "Hello, World!";
    // private static final String DEFAULT_CONNECTION_FACTORY = "java:jboss/exported/jms/RemoteConnectionFactory";
    private static final String DEFAULT_CONNECTION_FACTORY = "jms/RemoteConnectionFactory";
    // private static final String DEFAULT_DESTINATION = "java:jboss/exported/jms/topic/test";
    private static final String DEFAULT_DESTINATION = "jms/queue/test";
    private static final int DEFAULT_STARTING_INDEX = 0;
    private static final String DEFAULT_MESSAGE_COUNT = "10";
    private static final String DEFAULT_USERNAME = "jmsuser";
    private static final String DEFAULT_PASSWORD = "P@ssword00";
    private static final String INITIAL_CONTEXT_FACTORY = "org.wildfly.naming.client.WildFlyInitialContextFactory";
    private static final String PROVIDER_URL = "http-remoting://172.28.128.21:8080,http-remoting://172.28.128.22:8080,http-remoting://172.28.128.23:8080,http-remoting://172.28.128.24:8080";
    // private static final String PROVIDER_URL = "http-remoting://172.28.128.21:8080";
    // private static final String PROVIDER_URL = "http-remoting://172.28.128.22:8080";

    public static void main(String[] args) {

        Context namingContext = null;
        
        try {
            String userName = System.getProperty("username", DEFAULT_USERNAME);
            String password = System.getProperty("password", DEFAULT_PASSWORD);

            // Set up the namingContext for the JNDI lookup
            final Properties env = new Properties();
            env.put(Context.INITIAL_CONTEXT_FACTORY, INITIAL_CONTEXT_FACTORY);
            env.put(Context.PROVIDER_URL, System.getProperty(Context.PROVIDER_URL, PROVIDER_URL));
            env.put(Context.SECURITY_PRINCIPAL, userName);
            env.put(Context.SECURITY_CREDENTIALS, password);
            namingContext = new InitialContext(env);

            // Perform the JNDI lookups
            String connectionFactoryString = System.getProperty("connection.factory", DEFAULT_CONNECTION_FACTORY);
            log.info("Attempting to acquire connection factory \"" + connectionFactoryString + "\"");
            ConnectionFactory connectionFactory = (ConnectionFactory) namingContext.lookup(connectionFactoryString);
            log.info("Found connection factory \"" + connectionFactoryString + "\" in JNDI");

            String destinationString = System.getProperty("destination", DEFAULT_DESTINATION);
            log.info("Attempting to acquire destination \"" + destinationString + "\"");
            Destination destination = (Destination) namingContext.lookup(destinationString);
            log.info("Found destination \"" + destinationString + "\" in JNDI");

            
            int count = Integer.parseInt(System.getProperty("message.count", DEFAULT_MESSAGE_COUNT));
            String content = System.getProperty("message.content", DEFAULT_MESSAGE);

            try (JMSContext context = connectionFactory.createContext(userName, password)) {
                JMSConsumer consumer = context.createConsumer(destination);
                consumer.setMessageListener( m -> {
                    try {
                        var msg = m.getBody(String.class);
                        log.info("Received message with content: {}", msg);
                    } catch (JMSException e) {
                        log.error(e.getMessage(), e);
                    }
                });

                // log.info("Sending " + count + " messages with content: " + content);
                // // Send the specified number of messages
                // var jmsProducer =context.createProducer();
                // for (int i = DEFAULT_STARTING_INDEX; i < count + DEFAULT_STARTING_INDEX; i++) {
                //     jmsProducer.send(destination, content + ": " + i);
                // }
                // log.info("Sent all messages successfully");
                
                Thread.sleep(1000);

                
                
            }
        } catch (Exception e) {
            log.error(e.getMessage());
        } finally {
            if (namingContext != null) {
                try {
                    namingContext.close();
                } catch (NamingException e) {
                    log.error(e.getMessage());
                }
            }
        }
    }
    
    

}