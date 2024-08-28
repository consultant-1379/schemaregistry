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
        a subject and a schema
    when:
        the schema is compatible with the subject (according to the subjects compatibility level setting)
    then:
        register the schema under the subject and return the unique identifier of this schema in the registry
    ''')
    name('whenRegisterCompatibleSchema_thenReturnSchemaId')
    request {
        method(POST())
        url('/subjects/test/versions')
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body(file("test_schema.json"))
    }
    response {
        headers {
            contentType('application/vnd.schemaregistry.v1+json')
        }
        body(
            id: anyNumber()
        )
        status(OK())
    }
}
