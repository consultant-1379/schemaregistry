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
        the version parameter is a non-parseable integer except the string 'latest'
    then:
        return HTTP 422 Unprocessable Entitry error
    ''')
    name('whenSubjectInvalidVersion_thenReturnUnprocessableEntity')
    request {
        method GET()
        url('/subjects/contract/versions/xy')
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
    }
    response {
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body(
            error_code: 42202,
            message: $(
                consumer(anyNonEmptyString()),
                producer("""The specified version 'xy' is not a valid version id. Allowed values are between [1, 2^31-1] and the string \"latest\"""")
                )
        )
        status(UNPROCESSABLE_ENTITY())
    }
}
