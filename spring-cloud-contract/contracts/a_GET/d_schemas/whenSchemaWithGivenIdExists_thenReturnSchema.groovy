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
        returns the schema string identified by the input id
    ''')
    name('whenSchemaWithGivenIdExists_thenReturnSchema')
    request {
        method(GET())
        url('/schemas/ids/1') {
            queryParameters {
                parameter('subject', $(consumer(optional(regex('[a-z_-]*')))))
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
        body([
            schema: $(anyNonEmptyString())
        ])
        status(OK())
    }
}
