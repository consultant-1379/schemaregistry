# Schema Registry SR Service

## Description

**Schema Registry SR** is based on **Confluent Schema Registry**, a serving layer
service for filtering messages based on a schema.

**Schema Registry SR** can be used to accomplish the following tasks:

- Ensure that Apache Avro formatted messages sent between Producers and Consumers
  comply with schemas
- Assign a globally unique ID to each registered schema

## Resources

- Official documentation can be found on [ADP Marketplace][SR-guide]
- [Eridoc][SR-eridoc] documents folder *(BDGS OSS Product Documents > PDU OSS ADP Microservices > Schema Registry SR)*
- Product Structure / [PLM][SR-mimer]
  - [APR 201 492](https://munin.internal.ericsson.com/products/APR201492) *Schema Registry SR*
  - [CAV 101 066](https://munin.internal.ericsson.com/products/CAV10166) *Schema Registry SR*
  - [CXC 201 1691](https://munin.internal.ericsson.com/products/CXC2011691) *Schema Registry - Image*
  - [CXC 201 1692](https://munin.internal.ericsson.com/products/CXC2011692) *Schema Registry - Helm*
- Gerrit repository [AIA/microservices/schemaregistry][SR-gerrit]
- Jenkins *(fem2s11-eiffel112)*
  - [eric-data-schema-registry-sr_PreCodeReview](https://fem2s11-eiffel112.eiffel.gic.ericsson.se:8443/jenkins/search/?q=eric-data-schema-registry-sr_PreCodeReview) PreCodeReview (PCR) pipeline
  - [eric-data-schema-registry-sr](https://fem2s11-eiffel112.eiffel.gic.ericsson.se:8443/jenkins/search/?q=eric-data-schema-registry-sr) Service pipeline
  - [eric-data-schema-registry-sr-Release](https://fem2s11-eiffel112.eiffel.gic.ericsson.se:8443/jenkins/search/?q=eric-data-schema-registry-sr-Release) Release pipeline (for PRA releases)
  - [eric-data-schema-registry-sr-VA](https://fem2s11-eiffel112.eiffel.gic.ericsson.se:8443/jenkins/search/?q=eric-data-schema-registry-sr-VA) Vulnerability Analysis pipeline
  - [eric-schema-registry-sr-common-base-os-pra-listener](https://fem2s11-eiffel112.eiffel.gic.ericsson.se:8443/jenkins/search/?q=eric-schema-registry-sr-common-base-os-pra-listener) automatic CBOS PRA release integration pipeline
- Spinnaker flow [eric-data-schema-registry-sr-E2E-Flow](https://spinnaker.rnd.gic.ericsson.se/#/applications/eson_application/executions/configure/f0d7c980-803c-4352-a0b2-1628ff160059)
- [3PP Database][3PP-db] entry (registered as *IDUN-DMM-eric-schema-registry-sr*)

## Gerrit Project Details

**Schema Registry SR** artifacts are stored in the following Gerrit Project:
[AIA/microservices/schemaregistry](https://gerrit-gamma.gic.ericsson.se/#/admin/projects/AIA/microservices/schemaregistry)

## Repository structure

```
schemaregistry
 ┣ bragent
 ┃ ┣ Docker
 ┃ ┃ ┣ files
 ┃ ┃ ┗ Dockerfile                         -- Dockerfile for eric-oss-schema-registry-sr-bragent image
 ┃ ┣ src                                  -- sources for Schema Registry SR Backup and Restore Agent
 ┃ ┗ pom.xml
 ┣ Docker                                 -- artifacts required to build Schema Registry SR docker image
 ┃ ┣ files                                -- automatic Common Base OS uplift related artifacts
 ┃ ┣ include                              -- artifacts, mostly init scripts that will be included in the Docker image
 ┃ ┣ test                                 -- sources for Container Structure Tests, executed by `test-image` bob rule
 ┃ ┣ Dockerfile                           -- Dockerfile for eric-oss-schema-registry-sr image
 ┃ ┣ README.md
 ┃ ┣ stdout-redirect
 ┃ ┗ stdout-redirect.version
 ┣ Documentation
 ┣ Helm
 ┃ ┗ eric-oss-schema-registry-sr          -- Schema Registry SR Helm chart
 ┣ helm_kubectl_role_bind                 -- K8S role and rolebind definitions used during IT tests by testframework
 ┣ jenkins
 ┃ ┣ Jenkinsfile                          -- pipeline instructions for `eric-data-schema-registry-sr`, `eric-data-schema-registry-sr_PreCodeReview`
 ┃ ┣ Jenkinsfile.pra                      -- pipeline instructions for `eric-data-schema-registry-sr-Release`
 ┃ ┣ Jenkinsfile.va                       -- pipeline instructions for `eric-data-schema-registry-sr-VA`
 ┃ ┗ JenkinsfileUpdateBaseOS              -- pipeline instructions for `eric-schema-registry-sr-common-base-os-pra-listener`
 ┣ spring-cloud-contract
 ┃ ┣ contracts                            -- groovy contract test sources location
 ┃ ┗ Dockerfile                           -- Dockerfile usedto build image which runs contract tests
 ┣ test
 ┃ ┣ nose_auto.py                         -- integration tests for schema registry executed by testframework
 ┃ ┗ nose_auto_bur.py                     -- integration tests for schema registry backup and restore agent executed by testframework
 ┣ testframework                          -- testframework git submodule
 ┣ va-config                              -- configurations for various VA tools
 ┣ CONTRIBUTING.md
 ┣ README.md
 ┣ VERSION_PREFIX
 ┣ common-properties.yaml
 ┣ ruleset2.0.pra.yaml
 ┣ ruleset2.0.va.yaml
 ┗ ruleset2.0.yaml
```

## Contributing

We are an inner source project and welcome contributions. See our
[Contributing Guide](https://gerrit-gamma.gic.ericsson.se/plugins/gitiles/AIA/microservices/schemaregistry/+/master/CONTRIBUTING.md) for details.

## Contacts

For any related issues please contact
- Team Sunshine ([PDLTEAMSUN@pdl.internal.ericsson.com][mail])

## Bug Tracker (JIRA)

Use the [Schema Registry Bug Board][SR-bug-jira]

[3PP-db]: https://pdu-oss-tools2.seli.wh.rnd.internal.ericsson.com/3pp/login/#app-main
[mail]: PDLTEAMSUN@pdl.internal.ericsson.com
[SR-bug-jira]: https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-31850?jql=issuetype%20%3D%20Bug%20AND%20Sprint%20%3D%2036664
[SR-eridoc]: https://eridoc.internal.ericsson.com/eridoc/?docbase=eridoca&locateId=0b004cff8d635715
[SR-gerrit]: https://gerrit-gamma.gic.ericsson.se/#/admin/projects/AIA/microservices/schemaregistry
[SR-guide]: https://adp.ericsson.se/marketplace/schema-registry-sr/documentation/
[SR-mimer]: https://mimer.internal.ericsson.com/productPage?activeView=productDetails&productNumber=APR201492
