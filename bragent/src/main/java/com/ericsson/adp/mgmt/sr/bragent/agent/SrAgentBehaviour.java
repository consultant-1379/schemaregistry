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

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Stream;

import com.ericsson.adp.mgmt.bro.api.agent.AgentBehavior;
import com.ericsson.adp.mgmt.bro.api.agent.BackupExecutionActions;
import com.ericsson.adp.mgmt.bro.api.agent.RestoreExecutionActions;
import com.ericsson.adp.mgmt.bro.api.fragment.BackupFragmentInformation;
import com.ericsson.adp.mgmt.bro.api.fragment.FragmentInformation;
import com.ericsson.adp.mgmt.bro.api.registration.RegistrationInformation;
import com.ericsson.adp.mgmt.bro.api.registration.SoftwareVersion;

import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

/**
 * Responsible for backup and restoration tasks.
 */
@Service
public class SrAgentBehaviour implements AgentBehavior {

    private static final Logger LOG = LogManager.getLogger(SrAgentBehaviour.class);

    private SoftwareVersion softwareVersion;
    @Value("${sr.agent.softwareVersion.description}")
    private String softwareVersionDescription;
    @Value("${sr.agent.softwareVersion.productionDate}")
    private String softwareVersionProductionDate;
    @Value("${sr.agent.softwareVersion.type}")
    private String softwareVersionType;
    @Value("${sr.agent.softwareVersion.productName}")
    private String softwareVersionProductName;
    @Value("${sr.agent.softwareVersion.productNumber}")
    private String softwareVersionProductNumber;
    @Value("${sr.agent.softwareVersion.revision}")
    private String softwareVersionRevision;
    @Value("${sr.agent.scope}")
    private String scope;
    @Value("${sr.agent.id}")
    private String agentId;
    @Value("${sr.agent.apiVersion}")
    private String apiVersion;
    @Value("${sr.agent.download.location}")
    private String downloadLocation;
    @Value("${sr.agent.fragment.backup.data.path}")
    private String backupFilePath;
    @Value("${sr.agent.restore.softwareVersion.previousProductNumber}")
    private String restoreSoftwareVersionPreviousProductNumber;

    @Autowired
    private FragmentFactory fragmentFactory;

    @Autowired
    private SrRestoreHandler srRestoreHandler;

    @Autowired
    private SrBackupHandler srBackupHandler;

    @Override
    public RegistrationInformation getRegistrationInformation() {
        this.softwareVersion = new SoftwareVersion(softwareVersionProductName, softwareVersionProductNumber, softwareVersionRevision,
                softwareVersionProductionDate, softwareVersionDescription, softwareVersionType);
        return new RegistrationInformation(agentId, scope, apiVersion, this.getSoftwareVersion());
    }

    public SoftwareVersion getSoftwareVersion() {
        return this.softwareVersion;
    }

    @Override
    public void executeBackup(final BackupExecutionActions backupExecutionActions) {

        boolean success = false;
        String message;
        try {
            for (final BackupFragmentInformation fragment : createBackup()) {
                backupExecutionActions.sendBackup(fragment);
            }
            success = true;
            message = "The SR service has completed a backup for " + backupExecutionActions.getBackupName()
                    + " and the data has been sent to the orchestrator";
            LOG.info(message);
        } catch (final Exception e) {
            message = "The SR service failed to complete a backup " + backupExecutionActions.getBackupName() + " Cause: " + e.getMessage()
                    + " The SR service will not retry to send the backup";
            LOG.error(message);
            LOG.error(ExceptionUtils.getStackTrace(e));

        }
        backupExecutionActions.backupComplete(success, message);
        deleteFileAfterAction(backupFilePath);

    }

    @Override
    public void executeRestore(final RestoreExecutionActions restoreExecutionActions) {

        boolean success = false;
        String message;

        try {
            if (isCompatibleSoftwareVersion(restoreExecutionActions.getSoftwareVersion())) {
                final List<FragmentInformation> fragmentList = restoreExecutionActions.getFragmentList();
                LOG.info("Fragments received: {}", fragmentList);
                for (final FragmentInformation fragmentInformation : fragmentList) {
                    LOG.info("  Downloading fragment: {}", fragmentInformation);
                    restoreExecutionActions.downloadFragment(fragmentInformation, downloadLocation);
                }
                LOG.info("Starting restore...");

                srRestoreHandler.restoreFromFile(downloadLocation);

                success = true;
                message = "The SchemaRegistry service has completed restore of backup: " + restoreExecutionActions.getBackupName();

                LOG.info(message);
            } else {
                message = "Restore of backup " + restoreExecutionActions.getBackupName() + " failed due to software version incompatibility";
                LOG.error(message);
            }
        } catch (final Exception e) {
            message = "The SchemaRegistry service failed to complete restore of backup: " + restoreExecutionActions.getBackupName() + ", Cause: "
                    + e.getMessage();
            LOG.error(message);
            LOG.error(ExceptionUtils.getStackTrace(e));
        }

        restoreExecutionActions.restoreComplete(success, message);
        deleteFileAfterAction(downloadLocation);
    }

    private List<BackupFragmentInformation> createBackup() {
        srBackupHandler.backupToFile(backupFilePath);
        return fragmentFactory.getFragmentList();
    }

    /**
     * Deletes a given file.
     *
     * @param filePath path of file to be deleted
     * @throws FileException when {@link IOException} happens
     */
    public void deleteFileAfterAction(final String filePath) {
        final Path deleteFilePath = Paths.get(filePath);
        if (deleteFilePath.toFile().exists()) {
            try (Stream<Path> files = Files.walk(deleteFilePath)) {
                if (deleteFilePath.toFile().isDirectory()) {
                    files.sorted(Comparator.reverseOrder()).map(Path::toFile).forEach(File::delete);
                } else {
                    Files.delete(deleteFilePath);
                }
            } catch (final IOException e) {
                LOG.error(String.format("IOException occurred while deleting file: %s", e.getMessage()));
                throw new FileException(e);
            }
        }
    }

    /**
     * Checks if the software version is right.
     *
     * @param softwareVersion current version of the software
     * @return true if compatible false when not
     */
    public Boolean isCompatibleSoftwareVersion(final SoftwareVersion softwareVersion) {

        if (softwareVersion == null) {
            LOG.error("Backup Software Version is not set");
            return false;
        }

        if (!(this.softwareVersion.getProductName().equals(softwareVersion.getProductName())
                || "schema-registry-sr".equals(softwareVersion.getProductName()))) {
            LOG.error("Product Name does not match: expected " + this.softwareVersion.getProductName() + " instead received "
                    + softwareVersion.getProductName());
            return false;
        }

        if (!(this.softwareVersion.getProductNumber().equals(softwareVersion.getProductNumber())
                || "1".equals(softwareVersion.getProductNumber())
                || restoreSoftwareVersionPreviousProductNumber.trim().equals(softwareVersion.getProductNumber()))) {
            LOG.error("Product Number does not match: expected " + this.softwareVersion.getProductNumber() + " but got "
                    + softwareVersion.getProductNumber());
            return false;
        }

        if (!(this.softwareVersion.getRevision().equals(softwareVersion.getRevision()) || "revision number".equals(softwareVersion.getRevision()))) {
            LOG.error("Revision does not match: expected " + this.softwareVersion.getRevision() + " instead obtained "
                    + softwareVersion.getRevision());
            return false;
        }

        if (!(this.softwareVersion.getType().equals(softwareVersion.getType()) || "service".equals(softwareVersion.getType()))) {
            LOG.error("Type does not match: expected " + this.softwareVersion.getType() + " instead got "
                    + softwareVersion.getType());
            return false;
        }

        return true;
    }
}
