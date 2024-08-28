package com.ericsson.adp.mgmt.sr.bragent.agent;


import java.nio.file.Path;
import java.util.Arrays;
import java.util.Collections;
import java.util.Set;

import com.ericsson.adp.mgmt.sr.bragent.config.BackupConfiguration;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.TopicPartition;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.*;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.test.util.ReflectionTestUtils;

@ExtendWith(MockitoExtension.class)
public class SrBackupHandlerTest {

    public static final String KEY_1 = "key_1";
    public static final String KEY_2 = "key_2";
    public static final String VALUE_1 = "value_1";
    public static final String VALUE_2 = "value_2";
    private static final String SCHEMA_NAME = "_schemas";

    @Mock
    private BackupConfiguration factoryMock;

    @InjectMocks
    private SrBackupHandler objectUnderTest;

    @TempDir
    Path tempFileLocation;

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(objectUnderTest, "topicName", SCHEMA_NAME);
    }

    @Test
    void backupAndWriteTest(){
        final ConsumerFactory<String, String> consumerFactoryMock = (ConsumerFactory<String, String>) Mockito.mock(ConsumerFactory.class);
        final KafkaConsumer<String, String> kafkaConsumerMock = (KafkaConsumer<String, String>) Mockito.mock(KafkaConsumer.class);

        Mockito.when(factoryMock.schemaConsumerFactory()).thenReturn(consumerFactoryMock);
        Mockito.when(consumerFactoryMock.createConsumer()).thenReturn(kafkaConsumerMock);
        Mockito.when(kafkaConsumerMock.poll(100)).thenReturn(null);
        Mockito.when(kafkaConsumerMock.assignment()).thenReturn(Collections.singleton(new TopicPartition(SCHEMA_NAME, 0)));

        final ConsumerRecord<String, String> recordMock = (ConsumerRecord<String, String>) Mockito.mock(ConsumerRecord.class);
        final ConsumerRecords<String, String> consumerRecordsMock = (ConsumerRecords<String, String>) Mockito.mock(ConsumerRecords.class);
        Mockito.when(consumerRecordsMock.iterator()).thenReturn(Arrays.asList(recordMock, recordMock).iterator());

        Mockito.when(kafkaConsumerMock.poll(1_000))
                .thenReturn((consumerRecordsMock));

        Mockito.when(recordMock.key())
                .thenReturn(KEY_1)
                .thenReturn(KEY_2);

        Mockito.when(recordMock.value())
                .thenReturn(VALUE_1)
                .thenReturn(VALUE_1)
                .thenReturn(VALUE_2)
                .thenReturn(VALUE_2);

        final Path tempPath = tempFileLocation.resolve("temp_file.txt");
        objectUnderTest.backupToFile(tempPath.toFile().getAbsolutePath());

        final ArgumentCaptor<Set<TopicPartition>> topicCaptor = ArgumentCaptor.forClass(Set.class);
        Mockito.verify(kafkaConsumerMock).assign(topicCaptor.capture());
        Mockito.verify(kafkaConsumerMock).poll(100);

        final ArgumentCaptor<Set<TopicPartition>> topicSeekBeginningCaptor = ArgumentCaptor.forClass(Set.class);
        Mockito.verify(kafkaConsumerMock).seekToBeginning(topicSeekBeginningCaptor.capture());

        Mockito.verify(recordMock, Mockito.times(2)).key();
        Mockito.verify(recordMock, Mockito.times(4)).value();

        Mockito.verify(kafkaConsumerMock, Mockito.times(20)).commitSync();

        Assertions.assertThat(topicCaptor.getValue())
                .containsExactlyInAnyOrder(new TopicPartition(SCHEMA_NAME, 0));
        Assertions.assertThat(topicSeekBeginningCaptor.getValue())
                .containsExactlyInAnyOrder(new TopicPartition(SCHEMA_NAME, 0));

        Assertions.assertThat(tempPath)
                .hasContent(String.join("\r\n", KEY_1, VALUE_1, KEY_2, VALUE_2));
    }
}
