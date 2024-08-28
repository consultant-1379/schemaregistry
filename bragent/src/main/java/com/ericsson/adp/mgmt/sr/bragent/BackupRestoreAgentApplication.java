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

package com.ericsson.adp.mgmt.sr.bragent;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Main br agent application.
 */
@SpringBootApplication
@EnableScheduling
@SuppressWarnings("HideUtilityClassConstructor")
public class BackupRestoreAgentApplication {

    public static void main(final String[] args) {
        SpringApplication.run(BackupRestoreAgentApplication.class, args);
    }
}
