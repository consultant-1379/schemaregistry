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
        registered subjects
    when:
        the subjects endpoint is queried
    then:
        return list of registered subjects
    ''')
    name('whenServerIsOperational_thenListSubjects')
    request {
        method GET()
        url('/subjects') {
            queryParameters {
                parameter('deleted', $(consumer(optional(anyBoolean())), producer('false')))
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
        body('''\
["nose_test_topic_p1_r3_pw"]
        ''')
        status(OK())
    }
}
