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
        there are already schemas registered
    when:
        the schema schemas endpoint is queried
    then:
        return list of schemas matching the specified parameters
    ''')
    name('whenServerIsOperational_ThenReturnListOfSchemas')
    request {
        method GET()
        url('/schemas') {
            queryParameters {
                parameter('subjectPrefix', $(consumer(optional(anyAlphaNumeric())), producer('nose')))
                parameter('deleted', $(consumer(optional(anyBoolean())), producer('false')))
                parameter('latestOnly', $(consumer(optional(anyBoolean())), producer('false')))
                parameter('offset', $(consumer(optional(anyNumber())), producer(0)))
                parameter('limit', $(consumer(optional(anyNumber())), producer(-1)))
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
        body([[
            subject: $(consumer(anyNonEmptyString()), producer('nose_test_topic_p1_r3_pw')),
            version: $(consumer(anyPositiveInt()), producer('1')),
            id: $(consumer(anyPositiveInt()), producer('1')),
            schema: $(anyNonEmptyString())
        ]])
        status(OK())
    }
}
