# Schema Registry SR Developer's Guide

[TOC]

## Design Rules update policy

* The adp-helm-dr-check version should be kept as latest
* If the checker fails, the adp-helm-dr-check version should be downgraded manually to the latest working version
* In order to make sure that the failure indeed comes from the adp-helm-dr-check update - and not because of your
  changes - run bob package lint on master.
* Anyone who encounters the failure should inform the service guardian, and a Jira task should be created to comply
  with the changes in the latest version.
* After this task is done, the version of the adp-helm-dr-check should be upgraded to latest.

## Schema Registry client certificate

By default, **Schema Registry SR** deployment exposes only secure endpoints, so in order to be able to communicate
with the application a client certificate is required.

> **Note:** to disable client certificate validation, set `service.endpoints.schemaregistry.tls.verifyClientCertificate`
to `'optional'`

> **Note:** to expose insecure endpoints the following parameters can be used (more on them in
[Schema Registry SR User Guide][SR-guide])
- `global.security.tls.enabled`
- `service.endpoints.schemaregistry.tls.enforced`

### Generating the certificate

Since client certificate has to be signed by `eric-oss-schema-registry-sr-client-ca` Certificate Authority (CA) in order
to be accepted by **Schema Registry SR** service, the easiest method for generating one is letting [SIP-TLS][SIP-api-docs]
do the heavy lifting by creating an InternalCertificate resource.

```
cat <<EOF | kubectl apply -n <NAMESPACE> -f -
apiVersion: siptls.sec.ericsson.com/v1
kind: InternalCertificate
metadata:
  name: eric-oss-schema-registry-sr-client-cert
spec:
  kubernetes:
    generatedSecretName: eric-oss-schema-registry-sr-client-cert-secret
    certificateName: clientcert.pem   # name of the generated private certificate
    privateKeyName: clientkey.pem     # name of the generated private key
  certificate:
    subject:
      cn: eric-oss-schema-registry-sr
    issuer:
      reference: eric-oss-schema-registry-sr-client-ca    # reference the CA
    subjectAlternativeName:
      populateKubernetesDns: false
    extendedKeyUsage:
      tlsClientAuth: true
      tlsServerAuth: false
    validity:
      overrideTtl: 315360000    # will expire in 1 year
      overrideLeadTime:
EOF
```

Once the `eric-oss-schema-registry-sr-client-cert` resource is created, it's just a matter of extracting the privte certificate
and key files from the underlying kubernetes secret object. Alternatively, the secret can be mounted into a container and used
that way as well.

```
kubectl get secret -n <NAMESPACE> eric-oss-schema-registry-sr-client-cert-secret --template='{{ index .data "clientcert.pem" | base64decode }}' > clientcert.pem
kubectl get secret -n <NAMESPACE> eric-oss-schema-registry-sr-client-cert-secret --template='{{ index .data "clientkey.pem" | base64decode }}' > clientkey.pem
```

From this point forward the certificate can be used as

```
curl -X GET https://eric-oss-schema-registry-sr:8082/schemas -k --cert clientcert.pem --key clientkey.pem
```

### Contract Testing

#### Contract Definitons

The sources for *Schema Registry SR* contracts can be found in **schemaregistry/spring-cloud-contract/contracts** directory. The directory is structured as:

*/contracts/<letter\>\_<HTTP_method\>/<letter\>_<endpoint_name\>/<unique_contract_name\>.groovy*

- the *<letter\>_<endpoint_name\>* must be consistent across HTTP methods, e.g. *a_GET/**f_schemas** b_POST/**f_schemas***
- the *<unique_contract_name\>* must be unique across all contracts (auto-generated java stub test method names are derived from it, which must be unique otherwise the build will fail). A good practice is to match the filename with the name directive of the contract, e.g. (some_unique_name.yaml --> name: some_unique_name or some_unique_name.groovy --> name('some_unique_name'))

The contracts are defined using the groovy syntax of [Spring Cloud Contract DSL](https://docs.spring.io/spring-cloud-contract/docs/3.0.0/reference/htmlsingle/#features)

Currently the following [Schema Registry endpoints][SR-api-docs] are covered:

|Endpoint | HTTP Response |
|---|---|
|GET /config | 200 |
|GET /schemas | 200 |
|GET /schemas/ids/{id} | 200 |
|GET /schemas/ids/{id} | 404 |
|GET /schemas/ids/{id}/versions | 200 |
|GET /schemas/ids/{id}/versions | 404 |
|GET /schemas/types | 200 |
|GET /subjects | 200 |
|GET /subjects/{subject}/versions | 200 |
|GET /subjects/{subject}/versions | 404 |
|GET /subjects/{subject}/versions/{version} | 200 |
|GET /subjects/{subject}/versions/{version} | 404 |
|GET /subjects/{subject}/versions/{version} | 422 |
|GET /v1/metadata/id | 200 |
|POST / | 200 |
|POST /subjects/{subject} | 200 |
|POST /subjects/{subject} | 404 |
|POST /subjects/{subject} | 422 |
|POST /subjects/{subject}/versions | 200 |
|PUT /config | 200 |
|PUT /config | 422 |
|DELETE /subjects/{subject} | 200 |
|DELETE /subjects/{subject} | 404 |
|DELETE /subjects/{subject}/versions/{version} | 404 |

> **Note:** due to the limitation of Spring Cloud Contract framework and the uniqueness of Schema Registry API the schema definitions themselves (the *"schema"* JSON attribute) cannot be valideated using contracts alone

#### Generating Tests on the Producer Side

Stub generation involves the following steps

1. generating the contract tests
1. running the tests against a live *Schema Registry SR* instance
1. generating the WireMock stubs
1. publishing the stubs to [proj-eric-oss-release-local][SR-stubs] Artifactory repo

**Automatically**

Producer contracts are generated as part of the **Contract-Test** stage of *Schema Registry SR* Service Pipeline execution. The produced artifacts are then uploaded and stored in [proj-eric-oss-release-local][SR-stubs] repository.

**Manually**

Manual contract test generation can be performed by

1. cloning the [AIA/microservices/schemaregistry][SR-gerrit] repository
```
git clone ssh://gerrit-gamma.gic.ericsson.se:29418/AIA/microservices/schemaregistry
```

1. setting up the environment by executing the following bob rules in order from the repository's root
```
bob clean init image package test-k8s-bur
```

1. generating the stubs and running the tests
```
bob contract-test
```
Upon succession, the generated stubs jar will be copied to the **spring-cloud-contract** directory.
At the heart of the `contract-test` rule is the *armdocker.rnd.ericsson.se/proj-eric-oss-dev-test/springcloud/spring-cloud-contract:3.1.2* image which is a re-taged version of the image provided by the [Spring Cloud Contract Docker Project](https://cloud.spring.io/spring-cloud-contract/reference/html/docker-project.html) (for internal use). For more information on its internal workings please refer to the provided documentation.

1. manually deploying the produced stubs jar to your local mvn repository
```
mvn install:install-file -Dfile=./spring-cloud-contract/eric-oss-schema-registry-sr-<version>-stubs.jar -DgroupId=com.ericsson.oss.dmi -DartifactId=eric-oss-schema-registry-sr -Dversion=<version> -Dpackaging=jar -Dclassifier=stubs
```

#### Debugging

Verbose logging during contract generation and test execution is enabled by default when running `contract-test` rule. There are typically 2 reasons for failure:

1. incorrect [Spring Cloud Contract DSL](https://docs.spring.io/spring-cloud-contract/docs/3.0.0/reference/htmlsingle/#features) usage
1. incorrect contract logic

the causes for both be deduced from the console logs (piped into *bob-contract-test.log* file during CI execution).

### Running Stubs on the Consumer Side

Stubs can be run with various methods depending on your needs. Please refer to the official [Spring Cloud Contract documentation](https://docs.spring.io/spring-cloud-contract/docs/3.0.0/reference/htmlsingle/#features-stub-runner-junit) for possible configurations.

The included sample here demonstrates the JUnit4 approach. There are 2 steps to making it work:

1. prerequisite: familiarize yourself with the contents of [Contract Definitons](#contract-definitons) chapter and the [stubs jar][SR-stubs] for exact contract definitions
1. include the *spring-cloud-starter-contract-stub-runner* dependency in your project

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-contract-stub-runner</artifactId>
    <version>3.0.4</version>
    <scope>test</scope>
</dependency>
```
1. create a class to house your contract test methods
```
@RunWith(JUnit4.class)
public class ContractTest {
  private static final String stubs;  # Ivy notation {@code [groupId]:artifactId:[version]:[classifier]} of the stub
                                      # [version] MUST use exact versions, '+' notation won't work due to artifactory setup
  private static final StubRunnerOptions options;   # options for running the stub

  static {
    stubs = "com.ericsson.oss.dmi:eric-oss-schema-registry-sr:1.1.10:stubs";
    options = new StubRunnerOptionsBuilder().withStubsMode(StubRunnerProperties.StubsMode.REMOTE)  # you can use StubsMode.LOCAL if the stub has already been downloaded to your local mvn repo
                                            .withUsername("USERNAME")  # artifactory username
                                            .withPassword("PASSWORD")  # artifactory password
                                            .withStubRepositoryRoot("https://arm.seli.gic.ericsson.se/artifactory/proj-eric-oss-release-local/")
                                            .withMappingsOutputFolder("target/outputmappings")
                                            .withMinMaxPort(8080, 8080)  # the local port to use for the stubrunner/wiremock server
                                            .build();
  }

  @ClassRule
  public static StubRunnerRule stubRunnerRule = new StubRunnerRule().downloadStub(stubs)
                                                                    .options(options);
  @BeforeClass
  @AfterClass
  public static void setupProps() {
    System.clearProperty("stubrunner.repository.root");
    System.clearProperty("stubrunner.classifier");
  }

  @Test
  public void verifyStubsRunning() {
    assertThat(stubRunnerRule.findAllRunningStubs().isPresent("eric-oss-schema-registry-sr"));
    assertThat(stubRunnerRule.findAllRunningStubs().getEntry("eric-oss-schema-registry-sr").getKey().getVersion()).isEqualTo("1.1.10");
  }
```

[SIP-api-docs]: https://adp.ericsson.se/marketplace/service-identity-provider-tls/documentation/development/dpi/api-documentation
[SR-api-docs]: https://docs.confluent.io/platform/7.1.0/schema-registry/develop/api.html
[SR-gerrit]: https://gerrit-gamma.gic.ericsson.se/#/admin/projects/AIA/microservices/schemaregistry
[SR-guide]: https://adp.ericsson.se/marketplace/schema-registry-sr/documentation/
[SR-stubs]: https://arm.seli.gic.ericsson.se/artifactory/proj-eric-oss-release-local/com/ericsson/oss/dmi/eric-oss-schema-registry-sr/