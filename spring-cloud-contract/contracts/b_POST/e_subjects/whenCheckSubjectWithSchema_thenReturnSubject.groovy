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
        the body does contain the referenced subject
    then:
        return the subject
    ''')
    name('whenCheckSubjectWithSchema_thenReturnSubject')
    request {
        method(POST())
        url('/subjects/nose_test_topic_p1_r3_pw') {
            queryParameters {
                parameter('normalize', $(consumer(optional(anyBoolean())), producer('false')))
            }
        }
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body(file('schema.json'))
    }
    response {
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body($(consumer(file('subject.json')), producer(anyNonEmptyString())))
        status(OK())
    }
}
