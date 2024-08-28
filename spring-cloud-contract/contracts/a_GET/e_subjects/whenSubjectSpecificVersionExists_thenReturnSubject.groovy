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
        subjects endpoint is queried
    when:
        the subject with the given version exists
    then:
        return the subject
    ''')
    name('whenSubjectSpecificVersionExists_thenReturnSubject')
    request {
        method GET()
        url($(
            consumer(regex('/subjects/[0-9a-zA-Z_-]+/versions(/[0-9]+|/latest)')),
            producer('/subjects/nose_test_topic_p1_r3_pw/versions/latest')
        ))
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
            version: $(consumer(anyPositiveInt()), producer('1')),
            id: $(consumer(anyPositiveInt()), producer('1')),
            schema: $(anyNonEmptyString())
        ])
        status(OK())
    }
}
