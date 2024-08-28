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
    name('whenSubjectExists_thenItIsDeleted')
    request {
        method DELETE()
        url($(consumer(regex('/subjects/[0-9a-zA-Z_-]+')), producer('/subjects/test'))) {
            queryParameters {
                parameter('permanent', $(consumer(optional(anyBoolean())), producer('false')))
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
        body($(consumer('''[1, 2, 3, 4]'''), producer(anyNonEmptyString())))
        status(OK())
    }
}
