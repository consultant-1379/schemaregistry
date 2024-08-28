package com.ericsson.adp.mgmt.sr.bragent.agent;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;

import com.ericsson.adp.mgmt.bro.api.agent.BackupExecutionActions;
import com.ericsson.adp.mgmt.bro.api.agent.RestoreExecutionActions;
import com.ericsson.adp.mgmt.bro.api.exception.FailedToDownloadException;
import com.ericsson.adp.mgmt.bro.api.exception.FailedToTransferBackupException;
import com.ericsson.adp.mgmt.bro.api.fragment.BackupFragmentInformation;
import com.ericsson.adp.mgmt.bro.api.fragment.FragmentInformation;
import com.ericsson.adp.mgmt.bro.api.registration.SoftwareVersion;

import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
class SrAgentBehaviourTest {

    public static final String BACKUP_NAME = "backupName_1";
    public static final String BACKUP_FILE_NAME = "backup_file.txt";
    public static final String WORKING_DIR_NAME = "workingDirectory";
    public static final String BACKUP_FILE_PATH = "backupFilePath";

    public static final String BAD_PRODUCT_NAME = "bad_product_name";
    public static final String BAD_PRODUCT_NUMBER = "bad_product_number";
    public static final String BAD_REVISION = "bad_revision";
    public static final String BAD_TYPE = "bad_type";

    public static final String SOFTWARE_VERSION_DESCRIPTION = "softwareVersionDescription";
    public static final String SOFTWARE_VERSION_PRODUCTION_DATE = "softwareVersionProductionDate";
    public static final String SOFTWARE_VERSION_TYPE = "softwareVersionType";
    public static final String SOFTWARE_VERSION_PRODUCT_NAME = "softwareVersionProductName";
    public static final String SOFTWARE_VERSION_PRODUCT_NUMBER = "softwareVersionProductNumber";
    public static final String SOFTWARE_VERSION_REVISION = "softwareVersionRevision";
    public static final String RESTORE_SOFTWARE_VERSION_PREVIOUS_PRODUCT_NUMBER = "restoreSoftwareVersionPreviousProductNumber";

    public static final String FILE_NAME = "file_name";

    @Mock
    private FragmentFactory fragmentFactoryMock;

    @Mock
    private SrBackupHandler srBackupHandlerMock;

    @Mock
    private SrRestoreHandler srRestoreHandlerMock;

    @InjectMocks
    private SrAgentBehaviour objectUnderTest;

    @TempDir
    static Path tempDirectory;

    @TempDir
    static Path tempFileLocation;

    @BeforeEach
    void setUp() {

        ReflectionTestUtils.setField(objectUnderTest, "softwareVersionDescription", SOFTWARE_VERSION_DESCRIPTION);
        ReflectionTestUtils.setField(objectUnderTest, "softwareVersionProductionDate", SOFTWARE_VERSION_PRODUCTION_DATE);
        ReflectionTestUtils.setField(objectUnderTest, "softwareVersionType", SOFTWARE_VERSION_TYPE);
        ReflectionTestUtils.setField(objectUnderTest, "softwareVersionProductName", SOFTWARE_VERSION_PRODUCT_NAME);
        ReflectionTestUtils.setField(objectUnderTest, "softwareVersionProductNumber", SOFTWARE_VERSION_PRODUCT_NUMBER);
        ReflectionTestUtils.setField(objectUnderTest, "softwareVersionRevision", SOFTWARE_VERSION_REVISION);
        ReflectionTestUtils.setField(objectUnderTest, "restoreSoftwareVersionPreviousProductNumber", RESTORE_SOFTWARE_VERSION_PREVIOUS_PRODUCT_NUMBER);

        objectUnderTest.getRegistrationInformation();   //  To initialize softwareVersion
    }

    @Test
    public void backupExecutionShouldSucceed() throws FailedToTransferBackupException, IOException {
        Path workingDirectory = tempDirectory.resolve(WORKING_DIR_NAME);
        if (!workingDirectory.toFile().mkdir()) {
            Assertions.fail("workingDirectory was not created.");
        }

        Path backupFile = workingDirectory.resolve(BACKUP_FILE_NAME);
        Files.createFile(backupFile);
        ReflectionTestUtils.setField(objectUnderTest, "backupFilePath", workingDirectory.toFile().getAbsolutePath());

        final BackupExecutionActions backupExecutionActionsMock = Mockito.mock(BackupExecutionActions.class);
        final BackupFragmentInformation backupFragmentInformation = new BackupFragmentInformation();

        Mockito.when(fragmentFactoryMock.getFragmentList()).thenReturn(Collections.singletonList(backupFragmentInformation));
        Mockito.when(backupExecutionActionsMock.getBackupName()).thenReturn(BACKUP_NAME);

        objectUnderTest.executeBackup(backupExecutionActionsMock);

        Mockito.verify(srBackupHandlerMock).backupToFile(Mockito.anyString());
        Mockito.verify(fragmentFactoryMock).getFragmentList();

        Mockito.verify(backupExecutionActionsMock).sendBackup(backupFragmentInformation);
        Mockito.verify(backupExecutionActionsMock).getBackupName();
        Mockito.verify(backupExecutionActionsMock).backupComplete(true, "The SR service has completed a backup for "
                                                                            + BACKUP_NAME + " and the data has been sent to the orchestrator");
        Assertions.assertThat(tempDirectory).isEmptyDirectory();

        Mockito.verifyNoMoreInteractions(fragmentFactoryMock, srBackupHandlerMock, backupExecutionActionsMock);
    }

    @Test
    public void restoreExecutionSucceeds() throws FailedToDownloadException, IOException {
        final Path tempPath = tempFileLocation.resolve(FILE_NAME);

        try (BufferedWriter bufferedWriter = Files.newBufferedWriter(tempPath);
             PrintWriter printWriter = new PrintWriter(bufferedWriter)) {
            printWriter.println("restore_file");
        }

        ReflectionTestUtils.setField(objectUnderTest, "downloadLocation", tempPath.toFile().getAbsolutePath());

        final RestoreExecutionActions restoreExecutionActionsMock = Mockito.mock(RestoreExecutionActions.class);
        final FragmentInformation fragmentInformation = new FragmentInformation();

        Mockito.when(restoreExecutionActionsMock.getFragmentList()).thenReturn(Collections.singletonList(fragmentInformation));
        Mockito.doNothing().when(restoreExecutionActionsMock).downloadFragment(fragmentInformation, tempPath.toFile().getAbsolutePath());

        SoftwareVersion compatibleSoftwareVersion = new SoftwareVersion(SOFTWARE_VERSION_PRODUCT_NAME, SOFTWARE_VERSION_PRODUCT_NUMBER, SOFTWARE_VERSION_REVISION,
                                                        SOFTWARE_VERSION_PRODUCTION_DATE, SOFTWARE_VERSION_DESCRIPTION, SOFTWARE_VERSION_TYPE);
        Mockito.when(restoreExecutionActionsMock.getSoftwareVersion()).thenReturn(compatibleSoftwareVersion);
        Mockito.when(restoreExecutionActionsMock.getBackupName()).thenReturn(BACKUP_NAME);

        objectUnderTest.executeRestore(restoreExecutionActionsMock);

        Mockito.verify(restoreExecutionActionsMock).getSoftwareVersion();
        Mockito.verify(restoreExecutionActionsMock).getBackupName();
        Mockito.verify(srRestoreHandlerMock).restoreFromFile(Mockito.anyString());

        Assertions.assertThat(objectUnderTest.isCompatibleSoftwareVersion(restoreExecutionActionsMock.getSoftwareVersion())).isEqualTo(true);

        Mockito.verify(restoreExecutionActionsMock).restoreComplete(true, "The SchemaRegistry service has completed restore of backup: "
                                                                                    + BACKUP_NAME);

        Mockito.verifyNoMoreInteractions(fragmentFactoryMock, srRestoreHandlerMock, restoreExecutionActionsMock);
    }

    @Test
    public void softwareVersionIsNullRestoreShouldFail() throws IOException {
        makeRestoreFail(null);
    }

    @Test
    public void restoreShouldFailBecauseOfBadProductName() throws IOException {
        makeRestoreFail(new SoftwareVersion(BAD_PRODUCT_NAME, SOFTWARE_VERSION_PRODUCT_NUMBER, SOFTWARE_VERSION_REVISION,
                SOFTWARE_VERSION_PRODUCTION_DATE, SOFTWARE_VERSION_DESCRIPTION, SOFTWARE_VERSION_TYPE));
    }

    @Test
    public void restoreShouldFailBecauseOfBadProductNumber() throws IOException {
        makeRestoreFail(new SoftwareVersion(SOFTWARE_VERSION_PRODUCT_NAME, BAD_PRODUCT_NUMBER, SOFTWARE_VERSION_REVISION,
                SOFTWARE_VERSION_PRODUCTION_DATE, SOFTWARE_VERSION_DESCRIPTION, SOFTWARE_VERSION_TYPE));
    }

    @Test
    public void restoreShouldFailBecauseOfBadRevision() throws IOException {
        makeRestoreFail(new SoftwareVersion(SOFTWARE_VERSION_PRODUCT_NAME, SOFTWARE_VERSION_PRODUCT_NUMBER, BAD_REVISION,
                SOFTWARE_VERSION_PRODUCTION_DATE, SOFTWARE_VERSION_DESCRIPTION, SOFTWARE_VERSION_TYPE));
    }

    @Test
    public void restoreShouldFailBecauseOfBadType() throws IOException {
        makeRestoreFail(new SoftwareVersion(SOFTWARE_VERSION_PRODUCT_NAME, SOFTWARE_VERSION_PRODUCT_NUMBER, SOFTWARE_VERSION_REVISION,
                SOFTWARE_VERSION_PRODUCTION_DATE, SOFTWARE_VERSION_DESCRIPTION, BAD_TYPE));
    }

    public void makeRestoreFail(SoftwareVersion badSoftwareVersion) throws IOException {
        final Path tempPath = tempFileLocation.resolve(FILE_NAME);

        try (BufferedWriter bufferedWriter = Files.newBufferedWriter(tempPath);
             PrintWriter printWriter = new PrintWriter(bufferedWriter)) {
            printWriter.println("restore_file");
        }

        ReflectionTestUtils.setField(objectUnderTest, "downloadLocation", tempPath.toFile().getAbsolutePath());
        final RestoreExecutionActions restoreExecutionActionsMock = Mockito.mock(RestoreExecutionActions.class);

        Mockito.when(restoreExecutionActionsMock.getSoftwareVersion()).thenReturn(badSoftwareVersion);
        Mockito.when(restoreExecutionActionsMock.getBackupName()).thenReturn(BACKUP_NAME);

        objectUnderTest.executeRestore(restoreExecutionActionsMock);

        Mockito.verify(restoreExecutionActionsMock).getSoftwareVersion();
        Mockito.verify(restoreExecutionActionsMock).getBackupName();

        Assertions.assertThat(objectUnderTest.isCompatibleSoftwareVersion(restoreExecutionActionsMock.getSoftwareVersion())).isEqualTo(false);

        Mockito.verify(restoreExecutionActionsMock).restoreComplete(false, "Restore of backup " + BACKUP_NAME
                                                                        + " failed due to software version incompatibility");

    }

}