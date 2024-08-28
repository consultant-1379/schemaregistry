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
        subject parameter does not exist
    then:
        return HTTP 404 Not Found
    ''')
    name('whenSubjectDoesNotExist_thenReturnNotFound')
    request {
        method GET()
        url($(
            consumer(regex('/subjects/contract/versions(/[0-9]+|/latest)')),
            producer('/subjects/contract/versions/1')
        ))
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
