package com.ericsson.adp.mgmt.sr.bragent.agent;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import com.ericsson.adp.mgmt.bro.api.fragment.BackupFragmentInformation;

import org.assertj.core.api.Assertions;
import org.assertj.core.groups.Tuple;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;
import org.mockito.InjectMocks;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
public class FragmentFactoryTest {

    public static final String TEMP_FILE = "temp_file";
    private static final String FRAGMENT_VERSION = "0.0.0";
    private static final int FRAGMENT_NUMBER = 1;
    public static final String AGENT_ID = "agent_id";

    @InjectMocks
    private FragmentFactory objectUnderTest;

    @TempDir
    static Path tempFolder;


    @Test
    public void backupFragmentCreationWorks() throws IOException {
        final Path tempFile = tempFolder.resolve(TEMP_FILE);
        writeToFile(tempFile,1 ,1);

        ReflectionTestUtils.setField(objectUnderTest, "backupFilePath", tempFile.toFile().getAbsolutePath());
        ReflectionTestUtils.setField(objectUnderTest, "agentId", AGENT_ID);

        final List<BackupFragmentInformation> fragmentList = objectUnderTest.getFragmentList();

        Assertions.assertThat(fragmentList)
                .extracting(BackupFragmentInformation::getFragmentId,
                            BackupFragmentInformation::getSizeInBytes,
                            BackupFragmentInformation::getVersion,
                            BackupFragmentInformation::getBackupFilePath)
                .containsExactly(Tuple.tuple(String.format("%s_%s", AGENT_ID, FRAGMENT_NUMBER),
                                            "8",
                                            FRAGMENT_VERSION,
                                            tempFile.toFile().getAbsolutePath()));
    }

    @Test
    void shouldThrowFileException_WhenFilePathDoesNotExist(){
        String nonExistingPath = "nonExistingPath";
        ReflectionTestUtils.setField(objectUnderTest, "backupFilePath", nonExistingPath);

        Assertions.assertThatThrownBy(() -> objectUnderTest.getFragmentList())
                .isExactlyInstanceOf(FileException.class)
                .hasMessage("The file that was created for the backup has encountered a problem: " + nonExistingPath);
    }

    private static void writeToFile(final Path tempFile, final int value, int... values) throws IOException {
        try (final OutputStream outputStream = Files.newOutputStream(tempFile);
             final DataOutputStream dataOutputStream = new DataOutputStream(outputStream)){
            dataOutputStream.writeInt(value);

            for (final int valueToWrite : values) {
                dataOutputStream.writeInt(valueToWrite);
            }
        }
    }
}
