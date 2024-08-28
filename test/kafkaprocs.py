#!/usr/bin/env python3

import io

import avro.io
import avro.schema
import requests
from kafka import KafkaConsumer, KafkaProducer
from kafka.admin import KafkaAdminClient, NewTopic
from kafka.errors import KafkaTimeoutError

import utilprocs
from constants import Constants
from environment import Environment


def produce_messages(number_of_messages, protocol, port, kafka_topic, schema_registry_certificates):
    """
    Produces messages to a given Kafka topic.

    :param number_of_messages: amount of messages to produce
    :param protocol: HTTP / HTTPS protocol
    :param port: port on which Schema Registry is listening
    :param schema_registry_certificates: certificate files for Schema Registry
    :param kafka_topic: name of the Kafka topic
    """

    url = protocol + '://' + Constants.SCHEMA_REGISTRY_NAME + ':' + port + '/subjects/' + kafka_topic + '/versions/latest'
    headers = {
        'Accept': 'application/json'
    }

    response = requests.get(url, headers=headers, cert=schema_registry_certificates)
    response.raise_for_status()

    utilprocs.log('SR has schema p: ' + response.text)

    producer = create_producer()

    utilprocs.log('Started producing')
    try:
        try:
            _ = producer.partitions_for(kafka_topic)
        except KafkaTimeoutError as e:
            utilprocs.log(f"'{kafka_topic}' does not exist, creating it.")
            create_topic(name=kafka_topic)
        schema_string = response.json()['schema']
        utilprocs.log('Extracted schema: ' + schema_string)
        schema = avro.schema.Parse(schema_string)
        writer = avro.io.DatumWriter(schema)
        bytes_writer = io.BytesIO()
        encoder = avro.io.BinaryEncoder(bytes_writer)
        writer.write({"firstName": "Donald", "lastName": "Duck", "birthDate": 2020}, encoder)
        raw_bytes = bytes_writer.getvalue()
        for _ in range(number_of_messages):
            producer.send(kafka_topic, raw_bytes)
            producer.flush()
    except Exception as e:
        utilprocs.log(e.args)
        raise e

    utilprocs.log('Finished producing')


def consume_messages(protocol, port, kafka_topic, schema_registry_certificates) -> int:
    """
    Consumes messages from a given Kafka topic.

    :param protocol: HTTP / HTTPS protocol
    :param port: port on which Schema Registry is listening
    :param kafka_topic: name of the Kafka topic
    :param schema_registry_certificates: certificate files for Schema Registry
    :return: amount of consumed messages
    """

    url = protocol + '://' + Constants.SCHEMA_REGISTRY_NAME + ':' + port + '/subjects/' + kafka_topic + '/versions/latest'

    headers = {
        'Accept': 'application/json'
    }

    response = requests.get(url, headers=headers, cert=schema_registry_certificates)
    response.raise_for_status()

    count = 0
    schema = avro.schema.Parse(response.json()['schema'])
    consumer = create_consumer(kafka_topic)

    utilprocs.log('Starting consuming')
    for message in consumer:
        bytes_reader = io.BytesIO(message.value)
        decoder = avro.io.BinaryDecoder(bytes_reader)
        reader = avro.io.DatumReader(schema)
        user = reader.read(decoder)
        utilprocs.log(user)
        count += 1

    utilprocs.log('Finished consuming')
    return count


def create_producer() -> KafkaProducer:
    """
    Creates producer for Kafka.

    :return: created producer
    """

    environment = Environment()
    return KafkaProducer(bootstrap_servers=[f'{Constants.KAFKA_URL}:{environment.port_kafka}'],
                         retries=40,
                         max_block_ms=6000,
                         max_in_flight_requests_per_connection=1,
                         security_protocol=environment.security_protocol,
                         ssl_cafile=environment.ssl_cafile,
                         ssl_certfile=environment.ssl_certfile,
                         ssl_keyfile=environment.ssl_keyfile)


def create_consumer(kafka_topic) -> KafkaConsumer:
    """
    Creates consumer for a Kafka topic.

    :param kafka_topic: name of the Kafka topic to create consumer for
    :return: created consumer
    """

    environment = Environment()
    return KafkaConsumer(kafka_topic,
                         group_id='996',
                         bootstrap_servers=[f'{Constants.KAFKA_URL}:{environment.port_kafka}'],
                         auto_offset_reset='earliest',
                         enable_auto_commit=True,
                         consumer_timeout_ms=20000,
                         security_protocol=environment.security_protocol,
                         ssl_cafile=environment.ssl_cafile,
                         ssl_certfile=environment.ssl_certfile,
                         ssl_keyfile=environment.ssl_keyfile)

def create_admin_client() -> KafkaAdminClient:
    """
    Creates a KafkaAdminClient.

    :return: created admin client
    """
    environment = Environment()
    return KafkaAdminClient(bootstrap_servers=[f'{Constants.KAFKA_URL}:{environment.port_kafka}'],
                            security_protocol=environment.security_protocol,
                            ssl_cafile=environment.ssl_cafile,
                            ssl_certfile=environment.ssl_certfile,
                            ssl_keyfile=environment.ssl_keyfile)

def create_topic(name,
                 num_partitions=1,
                 replication_factor=1):
    """
    Create new topics in the cluster.

    :param name: topic name
    :param num_partitions: number of partitions for the topic
    :param replication_factor: replication factor of the topic
    :return: appropriate version of CreateTopicResponse class.
    """

    new_topic = NewTopic(name=name,
                         num_partitions=num_partitions,
                         replication_factor=replication_factor)
    admin_client = create_admin_client()
    return admin_client.create_topics(new_topics=[new_topic])
