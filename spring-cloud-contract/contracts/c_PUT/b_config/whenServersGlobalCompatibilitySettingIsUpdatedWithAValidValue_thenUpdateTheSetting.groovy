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
        the server's global compatiblity setting is updated with a valid value
    then:
        update the setting
    ''')
    name('whenServersGlobalCompatibilitySettingIsUpdatedWithAValidValue_thenUpdateTheSetting')
    request {
        method(PUT())
        url('/config')
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body(
            compatibility: $(anyOf('BACKWARD', 'BACKWARD_TRANSITIVE', 'FORWARD', 'FORWARD_TRANSITIVE', 'FULL', 'FULL_TRANSITIVE', 'NONE'))
        )
    }
    response {
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body(
            compatibility: $(fromRequest().body('compatibility'))
        )
        status(OK())
    }
}
