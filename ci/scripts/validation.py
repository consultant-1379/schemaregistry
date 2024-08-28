#
# COPYRIGHT Ericsson 2022
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#

import yaml
import json
from jsonschema import validate, ValidationError

def validate_yaml_with_schema(input_file, validate_schema_file):
    # Load YAML data from the file
    with open(input_file, 'r') as yaml_file:
        yaml_data = yaml.safe_load(yaml_file)
 
    # Load JSON schema from the file
    with open(validate_schema_file) as schema_file:
        json_schema = json.load(schema_file)
 
    try:
       # Perform JSON schema validation
        validate(yaml_data, json_schema)
        print("Validation successful!")
    except ValidationError as e:
        raise ValidationFailedError("Validation failed: {e}")
 
input_file = 'resource-model.yaml'
validate_schema_file = 'schema.json'
validate_yaml_with_schema(input_file, validate_schema_file)