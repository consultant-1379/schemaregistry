# Contributing to Schema Registry SR Service

When contributing to this repository, please **first discuss the change you wish
to make** in the discussion forum for the project or via email, or any other method
with the guardians [README.md][readme.md]
of this repository before making a change.

The following is a set of guidelines for contributing to **Schema Registry SR**
project. These are mostly guidelines, not rules. Use your best judgment, and
feel free to propose changes to this document submitting a patch.

[TOC]

## Code of Conduct

This project and everyone participating in it is governed by the
[ADP Code of Conduct][adp-code-of-conduct].
By participating, you are expected to uphold this code.

## Development Environment prerequisites

The development framework for **Schema Registry SR** is based on [bob][bob]. To be
able to run bob, the following tools need to exist on the host:

- python3
- bash
- docker

Bob expects you to have a valid docker login towards your docker registry on the
host, currently it can't handle automatic login by itself. If you are using
armdocker, then you can login with the following command:

```
docker login armdocker.rnd.ericsson.se
```

## How can I use this repository?

This repository contains the source code of **Schema Registry SR** service including
functional and test code, documentation and configuration files for manual and
automatic build and verification.

If you want to fix a bug or just want to experiment with adding a feature,
you'll want to try the service in your environment using a local copy of the
project's source.

You can start cloning the GIT repository to get your local copy:

```
git clone ssh://<userid>@gerrit-gamma.gic.ericsson.se:29418/AIA/microservices/schemaregistry
scp -p -P 29418 <userid>@gerrit-gamma.gic.ericsson.se:hooks/commit-msg schemaregistry/.git/hooks/
```

Once you have your local copy you can now build the service with the following command,
from the root directory:

```
bob init build-agent image package
```

You can verify your build running the tests located in the folder `test`
using the following command:

```
bob test-k8s-auto test-k8s-bur
```

If you are satisfied with your change and want to submit for review,
create a new git commit and then push it with the following:

```
git push origin HEAD:refs/for/master
```

> **Note:** Please follow the
[guidelines for contributors](#Submitting-Contributions)
before you push your change for review.

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report for **Schema Registry SR**.
Following these guidelines helps maintainers and the community understand your
report, reproduce the behavior, and find related reports.

Before creating bug reports, please check
[this list](#Before-Submitting-A-Bug-Report) as you might find out that you
 don't need to create one. When you are creating a bug report,
 please [include as many details as possible](#How-Do-I-Submit-A-Good_Bug-Report).

> **Note:** If you find a **Closed** issue that seems like it is the same
thing that you're experiencing, open a new issue and include a link to
the original issue in the body of your new one.

#### Before Submitting A Bug Report

- **Check the [Service User Guide][SR-guide].**
  You might be able to find the cause of the problem and fix things yourself.
- **Perform a search in [bug tickets][SR-bug-jira]**  to see if the problem has already been
reported. If it has **and the issue is still open**, add a comment to the
existing issue instead of opening a new one.

#### How Do I Submit A (Good) Bug Report?

Bugs are tracked as [Schema Registry Bug Template Ticket][SR-bug-template].

Explain the problem and include additional details to help maintainers reproduce
the problem:

- **Use a clear and descriptive title** for the issue to identify the problem.
- **Describe the exact steps which reproduce the problem** in as many
details as possible.
- **Include details about your configuration and environment**.
- **Describe the behavior you observed** and point out what exactly is
the problem with that behavior.
- **Explain which behavior you expected to see instead and why.**
- **If the problem wasn't triggered by a specific action**, describe what you
were doing before the problem happened.

### Suggesting Features

This section guides you through submitting an enhancement suggestion, including
completely new features and minor improvements to existing functionality.
Following these guidelines helps maintainers and the community understand your
suggestion and find related suggestions.

Before creating feature suggestions, please check
[this list](#Before-Submitting-A-Feature-Suggestion) as you might find out
that you don't need to create one. When you are creating a feature suggestion,
please [include as many details as possible](#How-Do-I-Submit-A-Good_Feature-Suggestion).

#### Before Submitting A Feature Suggestion

- **Check the [Service User Guide][SR-guide]** for tips, you might discover
that the feature is already available.
- **Perform a search in {% Project JIRA %}** to see if the feature has already been
suggested. If it has, add a comment to the existing issue instead of
opening a new one.
- **Perform a search in the [discussion forum][forum]** for the project to
see if that enhancement was discussed before.
If not, **consider starting a new thread** to get a quick preliminary
feedback from the project maintainers.

#### How Do I Submit A (Good) Feature Suggestion?

Feature suggestions are tracked as {% Project JIRA %}. Select the correct
component and create an issue on it providing the following information:

- **Use a clear and descriptive title** for the issue to identify
the suggestion.
- **Provide a step-by-step description of the suggested feature** in as many
details as possible.
- **Explain why this feature would be useful** to most users of the service.

### Submitting Contributions

This section guides you through submitting your own contribution, including bug
fixing, new features or any kind of improvement on the content of this
repository. The process described here has several goals:

- Maintain the project's quality
- Fix problems that are important to users
- Engage the community in working toward the best possible solution
- Enable a sustainable system for project's maintainers to review contributions

#### Before Submitting A Contribution

- **Engage the project maintainers** in the proper way so that they are prepared
  to receive your contribution and can provide valuable suggestion on the design
  choices. Follow the guidelines to [report a bug](#Reporting-Bugs) or to
  [propose an enhancement](#Suggesting-Features).

#### How Do I Submit A (Good) Contribution?

Please follow these steps to have your contribution considered by the
maintainers:

- **Provide a proper description of the change and the reason for it**,
referring to the associated JIRA issue if it exists.
- **Provide proper automatic tests to verify your change**, extending the
existing test suites or creating new ones in case of new features.
- **Update the project documentation if needed**. In case of new features,
they shall be properly described in the the relevant documentation.
- **Follow [commit message guidelines][commit-msg]** when submitting your
contribution for review.
- After you submit your contribution, **verify that the automatic
[CI pipeline][pipeline] for your change is passing**.
If the CI pipeline is failing, and you believe that the failure is unrelated to
your change, please leave a comment on the change request explaining why you
believe the failure is unrelated. A maintainer will re-run the pipeline for you.
If we conclude that the failure was a false positive, then we will open an issue
to track that problem.

While the prerequisites above must be satisfied prior to having your pull
request reviewed, the reviewer(s) may ask you to complete additional design
work, tests, or other changes before your change request can be ultimately
accepted.

## Git Commit Message Guidelines

- Respect the [commit message Design Rule][commit-dr] and follow the
  [ODP commit message template](https://confluence-oss.seli.wh.rnd.internal.ericsson.com/display/ODP/Commit+Message+Template)

### Example commit message

```
[<JIRA Issue Id>] <JIRA Issue Title>

BLANK LINE

<link to JIRA issue>

<optionally, any other info you want to add>

Change-Id: Ia1147f79572a8cf6c6014528f76ec4932f82cbc2
```

### Git Workflow

1. The **contributor** updates the artifact in the local repository.
1. The **contributor** pushes the update to Gerrit for review.
1. The **contributor** invites the **service guardian** (mandatory) and **other
  relevant parties** (optional) to the Gerrit review, and makes no further changes
  to the document until it is reviewed.
1. The **service guardian** reviews the document and gives a code-review score.
The code-review scores and corresponding workflow activities are as follows:
    - Score is +1
        A **reviewer** is happy with the changes but approval is required from
        another reviewer.
    - Score is +2
        The **service guardian** accepts the change and ensures publication to
        Calstore and to the ADP marketplace occurs.
    - Score is -1 or -2
        The **service guardian** and the **contributor** align to determine when and
        how the change is published.

## Uplifting components

Some of the components that **Schema Registry SR** service relies on do not have automatized
version uplift processes, so the task has to be carried out manually. The components include

1. **Confluent Schema Registry**
1. **ADP Log Shipper**
1. **JMX Exporter image**
1. **Backup and Restore Agent API**

### Confluent Schema Registry

A successful Confluent Schema Registry uplift comprises of the following steps:

1. Submit a Generic FOSS request for Confluent Schema Registry (*CAX1058886*)
  and Confluent Docker Utils (*CTX1022171*)
1. Build the Schema Registry binary from source
1. Upload the built artifact to Nexus
1. Build the docker-utils binary from source (required to run kafka init checks)
1. Update `Docker/Dockerfile` with the new artifact versions
1. Update Container Structure Tests
1. Update documentation, SVL

#### Building a specific version
*e.g. 6.1.0*

- Download the sources from [Bazaar](https://bazaar.internal.ericsson.com/index.php?search=schema-registry)

```
curl -L -O https://github.com/confluentinc/schema-registry/archive/v6.1.0.zip
```

- Unzip it

```
unzip v6.1.0.zip
rm v6.1.0.zip
```

- Build & package it

```
cd schema-registry*
mvn package -P standalone -DskipTests
```

#### Building a specific build
*e.g. 6.1.0-135*

- Download the sources from [Bazaar](https://bazaar.internal.ericsson.com/index.php?search=schema-registry)

```
curl -O -s -L https://github.com/confluentinc/schema-registry/archive/v6.1.0-135.zip
```

- Download the sources of the parent components ([rest-utils](https://github.com/confluentinc/rest-utils), [common](https://github.com/confluentinc/common), [kafka](https://github.com/confluentinc/kafka). Use the versions referred by the relevant pom file.

```
curl -O -s -L https://github.com/confluentinc/rest-utils/archive/refs/tags/v6.1.0-121.zip
curl -O -s -L https://github.com/confluentinc/common/archive/refs/tags/v6.1.0-106.zip
curl -O -s -L https://github.com/confluentinc/kafka/archive/refs/tags/v6.1.0-62-ccs.zip
```

- Unzip them

```
find . -name "*.zip" -exec unzip -q {} \;
rm ./*.zip
```

- Build the components (you must specify the nearest release version for the licence-file-generator, because the snapshot versions referred by the components' pom files are not publicly available)

```
export ALLOW_UNSIGNED=false
cd kafka*
./gradlew clean install -PscalaVersion=2.13 -x test
cd ..
cd common*
mvn install -DskipTests -Dio.confluent.license-file-generator.version=6.1.0
cd ..
cd rest-utils*
mvn install -DskipTests -Dio.confluent.license-file-generator.version=6.1.0
cd ..
cd schema-registry*
mvn package -P standalone -DskipTests -Dio.confluent.license-file-generator.version=6.1.0
```

#### Uploading to Nexus

Finally, the binary can be uploaded to Nexus using
<https://fem2s11-eiffel112.eiffel.gic.ericsson.se:8443/jenkins/job/Upload_3pp_to_nexus>
job.

#### How to build docker-utils from source

> **Note:** It is highly recommended to use identical versions to Confluent Schema Registry

- Download docker-utils sources from [common-docker](https://github.com/confluentinc/common-docker/tree/v7.1.0)

- Replace variables (eg ${CONFLUENT_VERSION}) with the actual version number (eg.7.1.0) in `docker-utils/pom.xml`

- Add a repository reference into `common-docker/pom.xml`

```
<repositories>
    <repository>
        <id>confluent</id>
            <url>https://packages.confluent.io/maven/</url>
     </repository>
</repositories>
```

- Build docker-utils

```
cd ./docker-utils
mvn clean install -DskipTests
```

- Copy the result file (`docker-utils/target`) into Schema Registry repository (`Docker/include/etc/confluent/docker`))

### ADP Log Shipper

The ADP Log Shipper Sidecar Helm Library (*CXA301014*) is required for centralized logging.
A successful uplift comprises of the following steps:

1. Find the latest [ADP Log Shipper](https://adp.ericsson.se/marketplace/log-shipper) release
1. Update `eric-product-info.yaml` with the logshipper image version of the latest release
1. Find the associated, latest version of [helm-library-logshipper-sidecar chart](https://arm.seli.gic.ericsson.se/artifactory/proj-adp-log-release/com/ericsson/bss/adp/log/eric-log-shipper/helm-library-logshipper-sidecar/)
1. Merge the contents of the .tar file with the contents of `Helm/eric-oss-schema-registry-sr/templates`,
  **do not simply overwrite** the files, merge the contents thoughtfully
1. Find the associated, latest [stdout-redirect](https://arm.seli.gic.ericsson.se/artifactory/proj-adp-log-release/com/ericsson/bss/adp/log/stdout-redirect/) binary version
1. Repleace the current `Docker/stdout-redirect` binary with the new version
1. Update `Docker/stdout-redirect.version` file
1. Update `Docker/Dockerfile` with the new artifact versions
1. Verify manually that log propagation still works as before
1. Update documentation, SVL

### JMX Exporter

JMX Exporter (*CXC2012016*) is required for propagating Schema Registry jmx metrics to metrics server/prometheus.
A successful uplift comprises of the following steps:

1. Find the latest [JXM Exporter](https://adp.ericsson.se/marketplace/jmx-exporter) release
1. Update `eric-product-info.yaml` with the exporter image version of the latest release
1. Run IT to verify
1. Update documentation, SVL

[3PP-db]: https://pdu-oss-tools2.seli.wh.rnd.internal.ericsson.com/3pp/login/#app-main
[adp-code-of-conduct]: https://gerrit-gamma.gic.ericsson.se/plugins/gitiles/adp-fw/adp-fw-templates/+/master/inner-source-templates/CODE_OF_CONDUCT.md
[bob]: https://gerrit-gamma.gic.ericsson.se/plugins/gitiles/adp-cicd/bob/
[commit-dr]: https://confluence.lmera.ericsson.se/display/AA/Artifact+handling+design+rules
[commit-msg]: #Git-Commit-Message-Guidelines
[inner-source]: https://adp.ericsson.se/overview/inner-source/inner-source-principles
[mail]: PDLTEAMSUN@pdl.internal.ericsson.com
[pipeline]: https://fem008-eiffel007.rnd.ki.sw.ericsson.se:8443/jenkins/view/ADP-Ref-App/job/adp-ref-catfacts-text-analyzer-precodereview-pipeline/
[readme.md]: https://gerrit-gamma.gic.ericsson.se/plugins/gitiles/AIA/microservices/schemaregistry/+/master/README.md
[SR-bug-jira]: https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-31850?jql=issuetype%20%3D%20Bug%20AND%20Sprint%20%3D%2036664
[SR-bug-template]: https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-5222
[SR-eridoc]: https://eridoc.internal.ericsson.com/eridoc/?docbase=eridoca&locateId=0b004cff8d635715
[SR-gerrit]: https://gerrit-gamma.gic.ericsson.se/#/admin/projects/AIA/microservices/schemaregistry
[SR-guide]: https://adp.ericsson.se/marketplace/schema-registry-sr/documentation/
[SR-jira]: https://jira-oss.seli.wh.rnd.internal.ericsson.com/browse/IDUN-32459?jql=sprint%20%3D%2037399
[SR-mimer]: https://mimer.internal.ericsson.com/productPage?activeView=productDetails&productNumber=APR201492