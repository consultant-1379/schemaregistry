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
        a schema id
    when:
        the schema with the id exists
    then:
        the subject-version pairs identified by the input id
    ''')
    name('whenSchemaWithGivenIdExists_thenListVersions')
    request {
        method(GET())
        url('/schemas/ids/1/versions')
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
    }
    response {
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body([
            subject: $(consumer(anyNonEmptyString()), producer('nose_test_topic_p1_r3_pw')),
            version: $(consumer(anyPositiveInt()), producer('1'))
        ])
        status(OK())
    }
}
