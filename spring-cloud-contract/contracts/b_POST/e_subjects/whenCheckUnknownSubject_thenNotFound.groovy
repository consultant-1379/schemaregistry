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
        the subject parameter refers to a non-existent one
    then:
        return HTTP 404 Not Found error
    ''')
    name('whenCheckUnknownSubject_thenNotFound')
    request {
        method(POST())
        url('/subjects/contract') {
            queryParameters {
                parameter('normalize', $(consumer(optional(anyBoolean())), producer('false')))
            }
        }
        headers {
            header('Content-Type', 'application/vnd.schemaregistry.v1+json')
        }
        body(file('test_schema.json'))
    }
    response {
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        status(NOT_FOUND())
    }
}
