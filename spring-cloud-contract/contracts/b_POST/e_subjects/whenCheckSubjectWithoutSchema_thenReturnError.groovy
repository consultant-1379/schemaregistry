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
        the body does not contain the referenced subject
    then:
        return HTTP 422 Unprocessable Entitry error
    ''')
    name('whenCheckSubjectWithoutSchema_thenReturnError')
    request {
        method(POST())
        url($(
            consumer(regex('/subjects/[0-9a-zA-Z_-]+')),
            producer('/subjects/nose_test_topic_p1_r3_pw')
        )) {
            queryParameters {
                parameter('normalize', $(consumer(optional(anyBoolean())), producer('false')))
            }
        }
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
    }
    response {
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body(
            error_code: 422,
            message: $(anyNonEmptyString())
        )
        status(UNPROCESSABLE_ENTITY())
    }
}
