package com.ericsson.adp.mgmt.sr.bragent.agent;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;

import java.nio.file.Path;

import com.ericsson.adp.mgmt.sr.bragent.config.RestoreConfiguration;

import org.apache.kafka.clients.producer.Callback;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.kafka.core.ProducerFactory;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
public class SrRestoreHandlerTest {

    public static final String SCHEMA_NAME = "schema_name";
    public static final String REC_VALUE = "rec_value";
    public static final String FILE_NAME = "temp_file.txt";
    public static final String TOPIC_NAME = "_schemas";

    @Mock
    private RestoreConfiguration factoryMock;

    @InjectMocks
    private SrRestoreHandler objectUnderTest;

    @TempDir
    static Path tempFileLocation;

    @Test
    void restoreWorksFineTest() throws IOException {
        ReflectionTestUtils.setField(objectUnderTest, "topicName", TOPIC_NAME);
        final ProducerFactory<String, String> producerFactoryMock = (ProducerFactory<String, String>) Mockito.mock(ProducerFactory.class);
        final Producer<String,String> producerMock = (Producer<String, String>) Mockito.mock(Producer.class);

        Mockito.when(factoryMock.producerFactory()).thenReturn(producerFactoryMock);
        Mockito.when(producerFactoryMock.createProducer()).thenReturn(producerMock);

        final Path tempPath = tempFileLocation.resolve(FILE_NAME);

        try (BufferedWriter bufferedWriter = Files.newBufferedWriter(tempPath);
             PrintWriter printWriter = new PrintWriter(bufferedWriter)) {
            printWriter.println(SCHEMA_NAME);
            printWriter.println(REC_VALUE);
        }

        objectUnderTest.restoreFromFile(tempFileLocation.toFile().getAbsolutePath());

        ArgumentCaptor<ProducerRecord<String,String>> producerRecordArgumentCaptor =  ArgumentCaptor.forClass(ProducerRecord.class);
        ArgumentCaptor<Callback> callbackArgumentCaptor = ArgumentCaptor.forClass(Callback.class);
        Mockito.verify(producerMock).send(producerRecordArgumentCaptor.capture(), callbackArgumentCaptor.capture());

        ProducerRecord<String, String> value = producerRecordArgumentCaptor.getValue();
        Assertions.assertThat(value.topic()).isEqualTo(TOPIC_NAME);
        Assertions.assertThat(value.value()).isEqualTo(REC_VALUE);
        Assertions.assertThat(value.key()).isEqualTo(SCHEMA_NAME);
    }
}
