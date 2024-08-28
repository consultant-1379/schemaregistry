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

import com.ericsson.adp.mgmt.sr.bragent.config.RestoreConfiguration;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

/**
 * Implements restoration logging.
 */
@Component
public class SrRestoreHandler {

    private static final Logger LOG = LogManager.getLogger(SrRestoreHandler.class);

    @Autowired
    RestoreConfiguration factory;

    @Value(value = "${kafka.brTopic}")
    private String topicName;

    /**
     * Logs the restoration process.
     *
     * @param fileLocation location of the file to restore.
     */
    public void restoreFromFile(final String fileLocation) {
        LOG.info("Starting Restore of data to topic: {}", topicName);
        LOG.debug("Creating producer for the data");

        Producer<String, String> producer = factory.producerFactory().createProducer();

        try {
            File f = new File(fileLocation);
            String[] files = f.list();
            LOG.info("Backup files to restore: {}", files.toString());
            if (files.length > 0) {
                for (String filePath : files) {
                    LOG.info("Restoring data from file: {}", filePath);
                    try (FileReader reader = new FileReader(fileLocation + "/" + filePath);
                            BufferedReader br = new BufferedReader(reader))
                    {
                        String line;
                        ProducerRecord<String, String> record;

                        while ((line = br.readLine()) != null) {
                            record = new ProducerRecord<>(topicName, line, br.readLine());
                            producer.send(record, (recordMetadata, exception) -> {
                                if (null != exception) {
                                    LOG.error("Unable to restore the backup. Error: {}", exception.getMessage());
                                }
                            });
                        }
                    }
                }
            } else {
                LOG.error("NO backup files found to restore");
            }
        } catch (final Exception e) {
            LOG.error("Error occurred while restoring the data. Error: {}", e.getMessage());
        }

        producer.close();
        LOG.info("Restore complete");
    }
}
