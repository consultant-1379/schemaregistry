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
        the schema with the id does not exist
    then:
        return HTTP 404 Not Found
    ''')
    name('whenSchemaWithGivenIdDoesNotExist_thenReturnNotFound')
    request {
        method GET()
        url($(
            consumer(regex('/schemas/ids/[1-9]{1}[0-9]*(/versions)?')),
            producer('/schemas/ids/999')
        )) {
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
            error_code: 40403,
            message: "Schema ${fromRequest().path(2)} not found"
        ])
        status(NOT_FOUND())
    }
}
