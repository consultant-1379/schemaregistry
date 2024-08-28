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
    name('whenSubjectDoesNotExist_thenItIsNotDeleted')
    request {
        method DELETE()
        url($(
            consumer(regex('/subjects/[0-9a-zA-Z_-]+')),
            producer('/subjects/contract')
        )) {
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
        body("""\
{
    "error_code": 40401,
    "message": "Subject '${fromRequest().path(1)}' not found."
}
        """)
        status(NOT_FOUND())
    }
}
