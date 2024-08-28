/*------------------------------------------------------------------------------
 *******************************************************************************
 * COPYRIGHT Ericsson 2022
 *
 * The copyright to the computer program(s) herein is the property of
 * Ericsson Inc. The programs may be used and/or copied only with written
 * permission from Ericsson Inc. or in accordance with the terms and
 * conditions stipulated in the agreement/contract under which the
 * program(s) have been supplied.
 *******************************************************************************
 *----------------------------------------------------------------------------*/

org.springframework.cloud.contract.spec.Contract.make {
    description('''
    given:
        a functional Schema Registry server with default configuration
    when:
        the metadata endpoint is queried
    then:
        return the server metadata
    ''')
    name('whenServerIsOperational_thenReturnServerMetadata')
    request {
        method(GET())
        url('/v1/metadata/id')
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
    }
    response {
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body("""\
{
    "scope": {
        "path": [],
        "clusters": {
            "kafka-cluster": "${$(anyNonEmptyString())}",
            "schema-registry-cluster": "schema-registry"
        }
    }
}
        """)
        status(OK())
    }
}
