# Schema Registry API Guide

---

This document provides instructions for using the Schema Registry API. The Schema Registry SR Service ensures that Apache Avro, JSON and Protobuf formatted messages sent between Producers and Consumers comply with schemas. It assigns an ID to each registered schema.

## **[Schemas](#Schemas)**
- GET /schemas
- GET /schemas/ids/{id}
- GET /schemas/types
- GET /schemas/ids/{id}/versions
## **[Subjects](#Subjects)**
 - GET /subjects
 - GET /subjects/{subject}/versions
 - DELETE /subjects/{subject}
 - GET /subjects/{subject}/versions/{version}
 - POST /subjects/{subject}/versions
 - POST /subjects/{subject}
 - DELETE /subjects/{subject}/versions/{version}
## **[Config](#Config)**
- GET /config
- PUT /config
## Prerequisite

### Schema Registry Service Connectivity Details

* * *

| Sl No. | Connectivity | Service Name | Port | Description |
| --- | --- | --- | --- | --- |
| 1.  | Internal | eric-oss-schema-registry-sr | 8081 | Use the service name and port for internal connectivity to schema-registry-sr. |

## Schemas

## GET /schemas

**Description:**
Get the schema 

**Request URL:**
`schemas/ids`

**Example:**
`curl -i -X GET http://{service_name}:{port_number}/schemas/ids`


**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /Schemas/ids | String | id (int) – the globally unique identifier of the schema

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /Schemas/ids | application/json | schema (string) – Schema identified by the ID

**Example:**
```
GET /schemas/ids/1 HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

```

**Responses:**

- **Status:200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | ok | [{"subject":"Kafka-key","version":1,"id":1,"schema":"\"string\""}]

## GET /schemas/ids/{id}

**Description:**
Retrieves only the schema identified by the input ID.

**Request URL:**
`schemas/ids/{id}`

**Example:**
`curl -i -X GET http://{service_name}:{port_number}/schemas/ids/1`


**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /schemas/ids/{id} | String | id (int) – the globally unique identifier of the schema

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /schemas/ids/{id} | application/json | schema (string) – Schema identified by the ID

**Example:**
```
GET /schemas/ids/1/schema HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

```

**Responses:**

- **Status:200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | ok | Content-Type: application/vnd.schemaregistry.v1+jsonVary: Accept-Encoding, User-AgentContent-Length:23{"schema":"\"string\""}
- **Status:404 - Not Found**

  * **Error code 40403 – Schema not found**

- **Status:500 - Internal Server Error**

  * **Error code 50001 – Error in the backend datastore**

## GET /schemas/types

**Description:**
Get the schema types that are registered with Schema Registry.

**Request URL:**
`/schemas/types`

**Example:**
`curl -X GET http://{service_name}:{port_number}/schemas/types`

**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /schemas/types | String | schema (string) – Schema types currently available on Schema Registry.

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /schemas/types | application/json | schema (string) – Schema types currently available on Schema Registry.


**Example**
```
GET /schemas/types HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json
  
```

**Responses:**

- **Status:200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | ok | ["JSON","PROTOBUF","AVRO"]


## GET /schemas/ids/{id}/versions

**Description:**
Get the subject-version pairs identified by the input ID.

**Request URL:**
`schemas/ids/{id}/versions`

**Example:**
`curl -i -X GET http://{service_name}:{port_number}/schemas/ids/1`

**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /schemas/ids/{id}/versions | String | id (int) – the globally unique identifier of the schema

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /schemas/ids/{id}/versions | application/json | subject (string) – Name of the subject
| /schemas/ids/{id}/versions | application/json | version (int) – Version of the returned schema

**Example**
```
GET /schemas/ids/1/versions HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json
  
```
**Responses:**

- **Status:200 - ok**

| Response Code | Description  | Response Data
| ------ | ------ | ------ |
| 200 | OK |  Content-Type:application/vnd.schemaregistry.v1+json Vary: Accept-Encoding, User-Agent Content-Length: 23 {"schema":"\"string\""}

- **Status:404 - Not Found**

  * **Error code 40403 – Schema not found**


- **Status:500 - Internal Server Error**

  * **Error code 50001 – Error in the backend datastore**

## subjects

## GET /subjects

**Description:**
Get a list of registered subjects. (For API usage examples, see List all subjects.)


**Request URL:**
` /subjects  `

**Example:**
`curl -X GET http://{service_name}:{port_number}/subjects`

**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| GET /subjects | String | subjectPrefix (string) – Add ?subjectPrefix= (as an empty string) at the end of this request to list subjects in the default context. 
| GET /subjects | String | deleted (boolean) – Add ?deleted=true at the end of this request to list both current and soft-deleted subjects. 

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| GET /subjects | application/json | name (string) – Subject

**Example**
```
GET /subjects HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

```

**Responses:**

- **Status:200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------ |
| 200 | ok | ["Kafka-key"]


## GET /subjects/{subject}/versions

**Description:**
Get a list of versions registered under the specified subject.

**Request URL:**
` /subjects/{subject}/versions	`

**Example:**
`curl -i -X GET http://{service_name}:{port_number}/subjects/Kafka-key/versions	`


**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /subjects/{subject}/versions | String | user-name which needs to be created


**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /subjects/{subject}/versions | application/json | version (int) – version of the schema registered under this subject

**Example:**
```
GET /subjects/kafka-key/versions HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json
```

**Responses:**

- **Status: 200 - ok**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | OK | [1]

- **Status:404 - Not Found**

  * **Error code 40401 – Subject not found**

## DELETE /subjects/{subject}

**Description:**
Deletes the specified subject and its associated compatibility level if registered. 

**Request URL:**
`DELETE /subjects/{subject}`

**Example:**
`curl -i -X DELETE http://{service_name}:{port_number}/subjects/Kafka-new`

**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /subjects/{subject} | String | subject (string) – the name of the subject
|  /subjects/{subject} | String | permanent (boolean) – Add ?permanent=true at the end of this request to specify a hard delete of the subject, which removes all associated metadata including the schema ID. The default is false.
|  /subjects/{subject} | String | version (int) – version of the schema deleted under this subject

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /subjects/{subject} | application/json | version (int) – version of the schema registered under this subject

**Example**
```
DELETE /subjects/kafka-key HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json
 
```

**Responses:**

- **Status: 200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | OK | [1]

- **Status: 404 - Not Found**
   * **Error code 40401 – Subject not found**

## GET /subjects/{subject}/versions/{version}

**Description:**
Get a specific version of the schema registered under this subject

**Request URL:**
` /subjects/{subject}/versions/{version} `

**Example:**
`curl -i -X GET http://{service_name}:{port_number}/subjects/Kafka-key/versions/1`

**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /subjects/{subject}/versions/{version} | String | subject (string) – Name of the subject
|  /subjects/{subject}/versions/{version} | String | version (versionId) – Version of the schema to be returned.

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /subjects/{subject}/versions/{version} | application/json | subject (string) – Name of the subject that this schema is registered under
|  /subjects/{subject}/versions/{version} | application/json | id (int) – Globally unique identifier of the schema
| /subjects/{subject}/versions/{version} | application/json | version (int) – Version of the returned schema
|  /subjects/{subject}/versions/{version} | application/json | schemaType (string) – The schema format: AVRO is the default (if no schema type is shown on the response, the type is AVRO), PROTOBUF, JSON
| /subjects/{subject}/versions/{version} | application/json | schema (string) – The schema string

**Example**
```
GET /subjects/kafka-key/versions/1 HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

```

**Responses:**

- **Status: 200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | OK | {"subject":"Kafka-key","version":1,"id":1,"schema":"\"string\""}

- **Status: 404 - Not Found**
   * **Error code 40401 – Subject not found**
   * **Error code 40402 – Version not found**
- **Status: 422 - Unprocessable Entity**
   * **Error code 42202 – Invalid version**

**Example:**
```
HTTP/1.1 422 Unprocessable Entity
Content-Type: application/vnd.schemaregistry.v1+json
{
    "error_code": 422,
    "message": "schema may not be empty"
}
```

## POST /subjects/{subject}/versions

**Description:**
Register a new schema under the specified subject. If no schemaType is supplied, schemaType is assumed to be AVRO.

**Request URL:**
`/subjects/{subject}/versions `

**Example:**
`curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
   --data '{"schema": "{\"type\": \"string\"}"}' \
   http://{service_name}:{port_number}/subjects/Kafka-key/versions`

**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /subjects/{subject}/versions | String | subject (string) – Subject under which the schema will be registered
|  /subjects/(string: subject)/versions | String | normalize (boolean) – Add ?normalize=true at the end of this request to normalize the schema. The default is false. 

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /subjects/{subject}/versions | application/json | schema – The schema string
|  /subjects/{subject}/versions | application/json |schemaType – Defines the schema format: AVRO (default), PROTOBUF, JSON (Optional)
|  /subjects/{subject}/versions | application/json |references – Specifies the names of referenced schemas (Optional). 
|  /subjects/{subject}/versions | application/json |metadata – Specifies the metadata for the schema (Optional). 
|  /subjects/{subject}/versions | application/json |ruleSet – Specifies the ruleSet for the schema (Optional). 

**Example**
```
POST /subjects/kafka-key/versions HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

{
  "schema":
    "{
       \"type\": \"record\",
       \"name\": \"kafka-key\",
       \"fields\":
         [
           {
             \"type\": \"string\",
             \"name\": \"field1\"
           },
           {
             \"type\": \"com.acme.Referenced\",
             \"name\": \"int\"
           }
          ]
     }",
  "schemaType": "AVRO",
  "references": [
    {
       "name": "com.acme.Referenced",
       "subject":  "childSubject",
       "version": 1
    }
  ]
}

```
**Responses:**

- **Status: 200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | OK | {"id":1}

- **Status: 201 - Created**
   
## POST /subjects/{subject}

**Description:**
Check if a schema has already been registered under the specified subject. If so, this returns the schema string along with its globally unique identifier, its version under this subject and the subject name.

**Request URL:**
`/subjects/{subject}`

**Example:**
`curl -X POST -H "Content-Type: application/vnd.schemaregistry.v1+json" \
--data '{"schema": "{\"type\": \"string\"}"}' \ http://{service_name}:{port_number}/subjects/Kafka-key`

**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /subjects/{subject} | String | subject (string) – Subject under which the schema will be registered
| /subjects/{subject} | String | normalize (boolean) – Add ?normalize=true at the end of this request to normalize the schema. The default is false. To learn more, see Schema normalization.

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
| /subjects/{subject} | application/json | schema – The schema string
| POST /subjects/(string: subject)/versions | application/json |schemaType – Defines the schema format: AVRO (default), PROTOBUF, JSON (Optional)
| /subjects/{subject} | application/json |references – Specifies the names of referenced schemas (Optional). To learn more, see Schema references.
| /subjects/{subject} | application/json |metadata – Specifies the metadata for the schema (Optional). To learn more, see “Metadata Properties” in Data Contracts for Schema Registry .
| /subjects/{subject} | application/json |ruleSet – Specifies the ruleSet for the schema (Optional). To learn more, see “Rules” in Data Contracts for Schema Registry.

**Example**
```
POST /subjects/kafka-key HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

{
      "schema":
         "{
                \"type\": \"record\",
                \"name\": \"kafka-key\",
                \"fields\":
                  [
                    {
                      \"type\": \"string\",
                      \"name\": \"field1\"
                    },
                    {
                      \"type\": \"int\",
                      \"name\": \"field2\"
                    }
                  ]
              }"
    }

```

**Responses:**

- **Status: 200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | OK | {"subject":"Kafka-key","version":1,"id":1,"schema":"\"string\""}

- **Status: 404 - Not Found**
   * **Error code 40401 – Subject not found**
   * **Error code 40402 – Version not found**
- **Status: 422 - Unprocessable Entity**
   * **Error code 42202 – Invalid version**

**Example:**
```
HTTP/1.1 422 Unprocessable Entity
Content-Type: application/vnd.schemaregistry.v1+json
{
    "error_code": 422,
    "message": "schema may not be empty"
}
```

## DELETE /subjects/{subject}/versions/{version}

**Description:**
Deletes a specific version of the schema registered under this subject. 

**Request URL:**
`/subjects/{subject}/versions/{version}`

**Example:**
`curl -i -X DELETE http://{service_name}:{port_number}/subjects/Kafka-key/versions/1`

**Path Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /subjects/{subject}/versions/{version} | String | subject (string) – Name of the subject
|  /subjects/{subject}/versions/{version} | String |version (versionId) – Version of the schema to be deleted. 

**Body Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /subjects/{subject}/versions/{version}  | application/json | int – Version of the deleted schema

**Example**
```
DELETE /subjects/kafka-key/versions/1 HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

```

**Responses:**

- **Status: 404 - Not Found**
   * **Error code 40401 – Subject not found**
- **Status: 422 - Unprocessable Entity**
   * **Error code 42202 – Invalid version** 

**Example:**
```
HTTP/1.1 422 Unprocessable Entity
Content-Type: application/vnd.schemaregistry.v1+json
{
    "error_code": 422,
    "message": "schema may not be empty"
}
``` 

## GET /config

**Description:**
Get configuration for global compatibility level, compatibility group, normalization, default metadata, and rule set.

**Request URL:**
`/config`

**Example:**
`curl -i -X GET http://{service_name}:{port_number}/config`

**Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /config | String | alias (string) – If alias is specified, then this subject is an alias for the the subject named by the alias. 
|  /config | String | normalize (boolean) – If true, then schemas are automatically normalized when registered or when passed during lookups. 
|  /config | String | compatibility (string) – New global compatibility level for the subject. Must be one of BACKWARD, BACKWARD_TRANSITIVE, FORWARD, FORWARD_TRANSITIVE, FULL, FULL_TRANSITIVE, NONE
|  /config | String | compatibilityGroup (string) – Only schemas that belong to the same compatibility group will be checked for compatibility.
|  /config | String | defaultMetadata (object) – Default value for the metadata to be used during schema registration. 
|  /config | String | overrideMetadata (object) – Override value for the metadata to be used during schema registration. 
|  /config | String | defaultRuleSet (object) – Default value for the ruleSet to be used during schema registration. 
|  /config | String | overrideRuleSet (object) – Override value for the ruleSet to be used during schema registration. 

**Example**
```
GET /config HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

```
**Responses:**

- **Status: 200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | OK |  Content-Type: application/vnd.schemaregistry.v1+json Vary: Accept-Encoding, User-Agent Content-Length: 33 {"compatibilityLevel":"BACKWARD"}


## PUT /config

**Description:**
Update the configuration for global compatibility level, compatibility group, schema normalization, default metadata, and rule set.

**Request URL:**
`/config/{subject}`

**Example:**
`curl -X PUT -H "Content-Type: application/vnd.schemaregistry.v1+json" --data '{"compatibility": "FULL"}' http://{service_name}:{port_number}/config/Kafka-key`

**Parameters:**

| Params | Type  | Description |
| ------ | ------ | ------ |
|  /config | String | alias (string) – If alias is specified, then this subject is an alias for the the subject named by the alias. 
|  /config | String | normalize (boolean) – If true, then schemas are automatically normalized when registered or when passed during lookups. 
|  /config | String | compatibility (string) – New global compatibility level for the subject. Must be one of BACKWARD, BACKWARD_TRANSITIVE, FORWARD, FORWARD_TRANSITIVE, FULL, FULL_TRANSITIVE, NONE
|  /config | String | compatibilityGroup (string) – Only schemas that belong to the same compatibility group will be checked for compatibility. 
|  /config | String | defaultMetadata (object) – Default value for the metadata to be used during schema registration. 
|  /config | String | overrideMetadata (object) – Override value for the metadata to be used during schema registration. 
|  /config | String | defaultRuleSet (object) – Default value for the ruleSet to be used during schema registration. 
|  /config | String | overrideRuleSet (object) – Override value for the ruleSet to be used during schema registration. 


**Example**
```
PUT /config/kafka-key HTTP/1.1
Host: schemaregistry.example.com
Accept: application/vnd.schemaregistry.v1+json, application/vnd.schemaregistry+json, application/json

{
  "compatibility": "FULL"
}
```
**Responses:**

- **Status: 200 - OK**

| Response Code | Description  | Response Data
| ------ | ------ | ------
| 200 | OK | {"compatibility":"FULL"}

- **Status: 422 - Unprocessable Entity**
   * **Error code 42202 – Invalid version** 

**Example:**
```
HTTP/1.1 422 Unprocessable Entity
Content-Type: application/vnd.schemaregistry.v1+json
{
    "error_code": 422,
    "message": "schema may not be empty"
}
```








