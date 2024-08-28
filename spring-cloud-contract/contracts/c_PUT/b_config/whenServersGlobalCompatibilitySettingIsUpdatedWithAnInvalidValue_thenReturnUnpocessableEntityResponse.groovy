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
        a functional Schema Registry server with default configuration
    when:
        the server's global compatiblity setting is updated with an invalid value
    then:
        return HTTP 422 Unprocessable Entity response
    ''')
    name('whenServersGlobalCompatibilitySettingIsUpdatedWithAnInvalidValue_thenReturnUnpocessableEntityResponse')
    request {
        method(PUT())
        url('/config')
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body(
            compatibility: $(consumer(regex('.*')), producer('INVALID_COMPATIBILITY'))
        )
    }
    response {
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body('''
{
    "error_code": 42203,
    "message": "Invalid compatibility level. Valid values are none, backward, forward, full, backward_transitive, forward_transitive, and full_transitive"
}
        ''')
        status(UNPROCESSABLE_ENTITY())
    }
}
