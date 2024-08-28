/*------------------------------------------------------------------------------
 *******************************************************************************
 * COPYRIGHT Ericsson 2021
 *
 * The copyright to the computer program(s) herein is the property of
 * Ericsson Inc. The programs may be used and/or copied only with written
 * permission from Ericsson Inc. or in accordance with the terms and
 * conditions stipulated in the agreement/contract under which the
 * program(s) have been supplied.
 *******************************************************************************
 *----------------------------------------------------------------------------*/

package com.ericsson.adp.mgmt.sr.bragent.agent;

import java.io.FileWriter;
import java.util.Collections;

import com.ericsson.adp.mgmt.sr.bragent.config.BackupConfiguration;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.TopicPartition;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Implements backup logging.
 */
@Component
public class SrBackupHandler {

    private static final Logger LOG = LogManager.getLogger(SrBackupHandler.class);

    @Autowired
    BackupConfiguration factory;

    @Value(value = "${kafka.brTopic}")
    private String topicName;

    /**
     * Calls the backup log method.
     *
     * @param filePath the log file path
     */
    public void backupToFile(final String filePath) {
        writeMessagesToFile(filePath);
    }

    private void writeMessagesToFile(final String filePath) {
        LOG.info("Starting Backup of data in topic: {}", topicName);
        LOG.debug("Creating consumer for the data");
        KafkaConsumer<String, String> consumer = (KafkaConsumer<String, String>) factory.schemaConsumerFactory().createConsumer();
        //log.debug("Unsubscribe to any of the previous topics");
        //consumer.unsubscribe();
        LOG.debug("Set the partition to read as 0 and read from beginning of the topic");
        TopicPartition topicPartition = new TopicPartition(topicName, 0);
        consumer.assign(Collections.singleton(topicPartition));
        consumer.poll(100);

        //Start from index 0
        consumer.seekToBeginning(consumer.assignment());

        // Wait for 20 read timeouts before concluding that there is no further data to read
        int maxTimeout = 20; //Wait for 20 seconds

        FileWriter outputFile = null;
        long count = 0;
        try {
            outputFile = new FileWriter(filePath);
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(1000);

                for (final ConsumerRecord<String, String> record : records) {
                    if (record.value() != null) {
                        outputFile.write(record.key());
                        outputFile.write("\r\n");
                        outputFile.write(record.value());
                        outputFile.write("\r\n");
                    }
                }
                count += records.count();

                if (null != records && records.count() == 0) {
                    maxTimeout--;
                }

                consumer.commitSync();
                if (maxTimeout <= 0) {
                    break;
                }
            }
            outputFile.close();
            LOG.info("Total Records in backup: {}", count);
        } catch (final Exception e) {
            LOG.error("Unable to write data to file. Error message: {}", e.getMessage());
        } finally {
            try {
                outputFile.close();
            } catch (final Exception e) {
                LOG.error("Unable to close file.");
            }
            consumer.unsubscribe();
        }
        LOG.info("Backup complete");
    }
}
