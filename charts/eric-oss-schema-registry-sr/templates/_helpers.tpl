{{/* vim: set filetype=mustache: */}}

{{/*
Create a map from ".Values.global" with defaults if missing in values file.
This hides defaults from values file.
*/}}
{{- define "eric-oss-schema-registry-sr.global" -}}
  {{- $globalDefaults := dict "annotations" (dict) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "internalIPFamily" "") -}}
  {{- $globalDefaults := merge $globalDefaults (dict "labels" (dict)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "nodeSelector" (dict)) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "pullSecret" "" ) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "imagePullPolicy" "IfNotPresent" )) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "repoPath" "")) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "registry" (dict "url" "armdocker.rnd.ericsson.se" )) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "security" (dict "tls" (dict "enabled" false))) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "security" (dict "policyBinding" (dict "create" false))) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "security" (dict "policyReferenceMap" (dict "default-restricted-security-policy" "default-restricted-security-policy"))) -}}
  {{- $globalDefaults := merge $globalDefaults (dict "timezone" "UTC") -}}
  {{ if .Values.global }}
    {{- mergeOverwrite $globalDefaults .Values.global | toJson -}}
  {{ else }}
    {{- $globalDefaults | toJson -}}
  {{ end }}
{{ end }}

{{/*
Argument: imageName
Returns image path of provided imageName based on eric-product-info.yaml.
*/}}
{{- define "eric-oss-schema-registry-sr.imagePath" }}
       {{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
       {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
       {{- $image := (get $productInfo.images .imageName) -}}
       {{- $registryUrl := $image.registry -}}
       {{- $repoPath := $image.repoPath -}}
       {{- $name := $image.name -}}
       {{- $tag := $image.tag -}}
	   {{- $values := index . "values" -}}
       {{- if $global.registry.url -}}
         {{- $registryUrl = $global.registry.url -}}
		 {{- if $global.registry.repoPath -}}
            {{- $repoPath = default $repoPath $global.registry.repoPath -}}
        {{- end -}} 
       {{- end -}}
       {{- if .Values.imageCredentials -}}
         {{- if hasKey .Values.imageCredentials .imageName -}}
           {{- $credImage := get .Values.imageCredentials .imageName }}
           {{- if $credImage.registry -}}
             {{- if $credImage.registry.url -}}
               {{- $registryUrl = $credImage.registry.url -}}
            {{- end -}}
           {{- end -}}
           {{- if not (kindIs "invalid" $credImage.repoPath) -}}
             {{- $repoPath = default $repoPath $credImage.repoPath -}}
           {{- end -}}
         {{- end -}}
         {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = default $repoPath .Values.imageCredentials.repoPath -}}
         {{- end -}}
       {{- end -}}
       {{- if $repoPath -}}
         {{- $repoPath = printf "%s/" $repoPath -}}
       {{- end -}}
       {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}


{{- /*
Generic function for merging annotations and labels (version: 1.0.1)
{
    context: string
    sources: [[sourceData: {key => value}]]
}
This generic merge function is added to improve user experience
and help ADP services comply with the following design rules:
  - DR-D1121-060 (global labels and annotations)
  - DR-D1121-065 (annotations can be attached by application
                  developers, or by deployment engineers)
  - DR-D1121-068 (labels can be attached by application
                  developers, or by deployment engineers)
  - DR-D1121-160 (strings used as parameter value shall always
                  be quoted)
Installation or template generation of the Helm chart fails when:
  - same key is listed multiple times with different values
  - when the input is not string
IMPORTANT: This function is distributed between services verbatim.
Fixes and updates to this function will require services to reapply
this function to their codebase. Until usage of library charts is
supported in ADP, we will keep the function hardcoded here.
*/ -}}
{{- define "eric-oss-schema-registry-sr.aggregatedMerge" -}}
  {{- $merged := dict -}}
  {{- $context := .context -}}
  {{- $location := .location -}}
  {{- range $sourceData := .sources -}}
    {{- range $key, $value := $sourceData -}}
      {{- /* FAIL: when the input is not string. */ -}}
      {{- if not (kindIs "string" $value) -}}
        {{- $problem := printf "Failed to merge keys for \"%s\" in \"%s\": invalid type" $context $location -}}
        {{- $details := printf "in \"%s\": \"%s\"." $key $value -}}
        {{- $reason := printf "The merge function only accepts strings as input." -}}
        {{- $solution := "To proceed, please pass the value as a string and try again." -}}
        {{- printf "%s %s %s %s" $problem $details $reason $solution | fail -}}
      {{- end -}}
      {{- if hasKey $merged $key -}}
        {{- $mergedValue := index $merged $key -}}
        {{- /* FAIL: when there are different values for a key. */ -}}
        {{- if ne $mergedValue $value -}}
          {{- $problem := printf "Failed to merge keys for \"%s\" in \"%s\": key duplication in" $context $location -}}
          {{- $details := printf "\"%s\": (\"%s\", \"%s\")." $key $mergedValue $value -}}
          {{- $reason := printf "The same key cannot have different values." -}}
          {{- $solution := "To proceed, please resolve the conflict and try again." -}}
          {{- printf "%s %s %s %s" $problem $details $reason $solution | fail -}}
        {{- end -}}
      {{- end -}}
      {{- $_ := set $merged $key $value -}}
    {{- end -}}
  {{- end -}}
{{- /*
Strings used as parameter value shall always be quoted. (DR-D1121-160)
The below is a workaround to toYaml, which removes the quotes.
Instead we loop over and quote each value.
*/ -}}
{{- range $key, $value := $merged }}
{{ $key }}: {{ $value | quote }}
{{- end -}}
{{- end -}}

{{- /*
Wrapper functions to set the contexts
*/ -}}
{{- define "eric-oss-schema-registry-sr.mergeAnnotations" -}}
  {{- include "eric-oss-schema-registry-sr.aggregatedMerge" (dict "context" "annotations" "location" .location "sources" .sources) }}
{{- end -}}
{{- define "eric-oss-schema-registry-sr.mergeLabels" -}}
  {{- include "eric-oss-schema-registry-sr.aggregatedMerge" (dict "context" "labels" "location" .location "sources" .sources) }}
{{- end -}}

{{/*
Standard labels of Helm and Kubernetes
*/}}
{{- define "eric-oss-schema-registry-sr.standard-labels" -}}
app.kubernetes.io/name: {{ template "eric-oss-schema-registry-sr.name" . }}
app.kubernetes.io/version: {{ template "eric-oss-schema-registry-sr.version" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app: {{ template "eric-oss-schema-registry-sr.name" . }}
chart: {{ template "eric-oss-schema-registry-sr.chart" . }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
{{- end -}}

{{/*
Create a user defined label (DR-D1121-068, DR-D1121-060)
*/}}
{{ define "eric-oss-schema-registry-sr.config-labels" }}
  {{- $global := (.Values.global).labels -}}
  {{- $service := .Values.labels -}}
  {{- include "eric-oss-schema-registry-sr.mergeLabels" (dict "location" .Template.Name "sources" (list $global $service)) }}
{{- end }}

{{/*
Merged labels for Default, which includes Standard and Config
*/}}
{{- define "eric-oss-schema-registry-sr.labels" -}}
  {{- $standard := include "eric-oss-schema-registry-sr.standard-labels" . | fromYaml -}}
  {{- $config := include "eric-oss-schema-registry-sr.config-labels" . | fromYaml -}}
  {{- include "eric-oss-schema-registry-sr.mergeLabels" (dict "location" .Template.Name "sources" (list $standard $config)) | trim }}
{{- end -}}

{{/*
Create annotation for the product information (DR-D1121-064, DR-D1121-067)
*/}}
{{- define "eric-oss-schema-registry-sr.product-info" -}}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{ regexReplaceAll "(.*)[+|-].*" .Chart.Version "${1}" | quote }}
{{- end }}

{{/*
Create a user defined annotation (DR-D1121-065, DR-D1121-060)
*/}}
{{ define "eric-oss-schema-registry-sr.config-annotations" }}
  {{- $global := (.Values.global).annotations -}}
  {{- $service := .Values.annotations -}}
  {{- include "eric-oss-schema-registry-sr.mergeAnnotations" (dict "location" .Template.Name "sources" (list $global $service)) }}
{{- end }}
{{/*
Merged annotations for Default, which includes productInfo and config
*/}}
{{- define "eric-oss-schema-registry-sr.annotations" -}}
  {{- $productInfo := include "eric-oss-schema-registry-sr.product-info" . | fromYaml -}}
  {{- $config := include "eric-oss-schema-registry-sr.config-annotations" . | fromYaml -}}
  {{- include "eric-oss-schema-registry-sr.mergeAnnotations" (dict "location" .Template.Name "sources" (list $productInfo $config)) | trim }}
{{- end -}}

{{/*
Define the annotations for security-policy
*/}}
{{- define "eric-oss-schema-registry-sr.securityPolicy.annotations" -}}
ericsson.com/security-policy.name: "restricted/default"
ericsson.com/security-policy.privileged: "false"
ericsson.com/security-policy.capabilities: ""
{{- end -}}

{{/*
Define global imagePullPolicy (DR-D1121-102)
Template is needed to deprecate .Values.imagePullPolicy
*/}}
{{- define "eric-oss-schema-registry-sr.imagePullPolicy" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{- if .Values.imagePullPolicy -}}
  {{- .Values.imagePullPolicy -}}
{{- else -}}
  {{- $global.registry.imagePullPolicy -}}
{{- end -}}
{{- end -}}

{{/*
Volume information.
*/}}
{{- define "eric-oss-schema-registry-sr.volumes" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{- $serviceMesh := ( include "eric-oss-schema-registry-sr.service-mesh-enabled" . ) -}}
{{-  if and (eq $serviceMesh "false")  $global.security.tls.enabled }}
- name: secrets-directory
  emptyDir: {}
- name: siptls-ca
  secret:
    secretName: "eric-sec-sip-tls-trusted-root-cert"
- name: client-ca
  secret:
    secretName: {{ include "eric-oss-schema-registry-sr.client-ca-secret" . | quote }}
- name: server-cert
  secret:
    secretName: {{ include "eric-oss-schema-registry-sr.server-cert-secret" . | quote }}
- name: kafka-client-cert
  secret:
    secretName: {{ include "eric-oss-schema-registry-sr.kafka-client-cert-secret" . | quote }}
  {{- if eq (include "eric-oss-schema-registry-sr.jmx-exporter-tls" .) "true" }}
- name: jmx-exporter-client-cert
  secret:
    secretName: {{ include "eric-oss-schema-registry-sr.jmx-exporter-client-cert-secret" . | quote }}
  {{- end -}}
  {{- if .Values.ingress.caCertificateSecret }}
- name: ingress-ca
  secret:
    secretName: {{ .Values.ingress.caCertificateSecret }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "eric-oss-schema-registry-sr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eric-oss-schema-registry-sr.chart" -}}
{{- printf "%v-%v" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart version as used by the version label.
*/}}
{{- define "eric-oss-schema-registry-sr.version" -}}
{{- printf "%s" .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the schema registry kafkastore connection URL
*/}}
{{- define "eric-oss-schema-registry-sr.kf-url" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{ $kf := .Values.messagebuskf }}
{{- if eq .Values.service.endpoints.messagebuskf.tls.enforced "optional" -}}
  {{- if $global.security.tls.enabled -}}
    {{- printf "SSL://%v:%v,PLAINTEXT://%v:%v" $kf.clientServiceName $kf.secureClientPort $kf.clientServiceName $kf.clientPort -}}
  {{- else -}}
    {{- printf "PLAINTEXT://%v:%v" $kf.clientServiceName $kf.clientPort -}}
  {{- end -}}
{{- else if eq .Values.service.endpoints.messagebuskf.tls.enforced "required" -}}
  {{- if $global.security.tls.enabled -}}
      {{- printf "SSL://%v:%v" $kf.clientServiceName $kf.secureClientPort -}}
  {{- else -}}
    {{- printf "PLAINTEXT://%v:%v" $kf.clientServiceName $kf.clientPort -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-oss-schema-registry-sr.pullSecrets" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
  {{- if .Values.imageCredentials.pullSecret -}}
    {{- print .Values.imageCredentials.pullSecret -}}
  {{- else -}}
    {{- print $global.pullSecret -}}
  {{- end -}}
{{- end -}}

{{/*
Enable plaintext communication
*/}}
{{- define "eric-oss-schema-registry-sr.plaintext.enabled" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{- if or (not $global.security.tls.enabled) (eq .Values.service.endpoints.schemaregistry.tls.enforced "optional") -}}
true
{{- end -}}
{{- end -}}

{{/*
Define listener port mapping.
*/}}
{{- define "eric-oss-schema-registry-sr.listener" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{- if eq .Values.service.endpoints.schemaregistry.tls.enforced "optional" -}}
    {{- if $global.security.tls.enabled -}}
    http://0.0.0.0:{{ .Values.security.plaintext.schemaregistry.port }}, https://0.0.0.0:{{ .Values.security.tls.schemaregistry.port }}
    {{- else -}}
    http://0.0.0.0:{{ .Values.security.plaintext.schemaregistry.port }}
    {{- end -}}
{{- else if eq .Values.service.endpoints.schemaregistry.tls.enforced "required" -}}
    {{- if $global.security.tls.enabled -}}
    https://0.0.0.0:{{ .Values.security.tls.schemaregistry.port }}
    {{- else -}}
    http://0.0.0.0:{{ .Values.security.plaintext.schemaregistry.port }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level - schemaregistry.
*/}}
{{- define "eric-oss-schema-registry-sr.schemaregistryNodeSelector" -}}
{{- $globalValue := (dict) -}}
{{- if .Values.global -}}
    {{- if .Values.global.nodeSelector -}}
         {{- $globalValue = .Values.global.nodeSelector -}}
    {{- end -}}
{{- end -}}
{{- if .Values.nodeSelector.schemaregistry -}}
  {{- range $key, $localValue := .Values.nodeSelector.schemaregistry -}}
    {{- if hasKey $globalValue $key -}}
         {{- $Value := index $globalValue $key -}}
         {{- if ne $Value $localValue -}}
           {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
         {{- end -}}
     {{- end -}}
    {{- end -}}
    nodeSelector: {{- toYaml (merge $globalValue .Values.nodeSelector.schemaregistry) | trim | nindent 2 -}}
{{- else -}}
  {{- if not ( empty $globalValue ) -}}
    nodeSelector: {{- toYaml $globalValue | trim | nindent 2 -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Schema Registry CA Secret Name
*/}}
{{- define "eric-oss-schema-registry-sr.client-ca-secret" -}}
{{ template "eric-oss-schema-registry-sr.name" . }}-client-ca-secret
{{- end -}}

{{/*
Schema Registry Server Cert Secret Name
*/}}
{{- define "eric-oss-schema-registry-sr.server-cert-secret" -}}
{{ template "eric-oss-schema-registry-sr.name" . }}-server-cert-secret
{{- end -}}

{{/*
Kafka Client Cert Secret Name
*/}}
{{- define "eric-oss-schema-registry-sr.kafka-client-cert-secret" -}}
{{ template "eric-oss-schema-registry-sr.name" . }}-kafka-client-cert-secret
{{- end -}}

{{/*
JMX Exporter Client Cert Secret Name
*/}}
{{- define "eric-oss-schema-registry-sr.jmx-exporter-client-cert-secret" -}}
{{ template "eric-oss-schema-registry-sr.name" . }}-jmx-exporter-client-cert-secret
{{- end -}}

{{/*
Volume Mount information.
*/}}
{{- define "eric-oss-schema-registry-sr.secretsMountPath" }}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{- $serviceMesh := ( include "eric-oss-schema-registry-sr.service-mesh-enabled" . ) -}}
{{-  if and (eq $serviceMesh "false")  $global.security.tls.enabled }}
- name: secrets-directory
  mountPath: {{ include "eric-oss-schema-registry-sr.secrets-directory" . | quote }}
- name: siptls-ca
  mountPath: {{ include "eric-oss-schema-registry-sr.sip-tls-ca-directory" . | quote }}
- name: client-ca
  mountPath: {{ include "eric-oss-schema-registry-sr.client-ca-directory" . | quote }}
- name: server-cert
  mountPath: {{ include "eric-oss-schema-registry-sr.server-cert-directory" . | quote }}
- name: kafka-client-cert
  mountPath: {{ include "eric-oss-schema-registry-sr.kafka-client-cert-directory" . | quote }}
  {{- if eq (include "eric-oss-schema-registry-sr.jmx-exporter-tls" .) "true" }}
- name: jmx-exporter-client-cert
  mountPath: {{ include "eric-oss-schema-registry-sr.jmx-exporter-client-cert-directory" . | quote }}
  {{- end -}}
  {{- if .Values.ingress.caCertificateSecret}}
- name: ingress-ca
  mountPath: {{ include "eric-oss-schema-registry-sr.ingressca" . | quote }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Base directory of TLS related artifacts (keys, certificates, key/truststores etc.)
*/}}
{{- define "eric-oss-schema-registry-sr.secrets-directory" -}}
/etc/schema-registry/secrets
{{- end -}}

{{/*
SIP TLS CA location
*/}}
{{- define "eric-oss-schema-registry-sr.sip-tls-ca-directory" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/siptls-ca
{{- end -}}

{{/*
Ingress CA certificate authority location
*/}}
{{- define "eric-oss-schema-registry-sr.ingressca" -}}
/etc/schema-registry/secrets/ingressca
{{- end -}}

{{/*
Schema Registry client CA location
*/}}
{{- define "eric-oss-schema-registry-sr.client-ca-directory" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/client-ca
{{- end -}}

{{/*
Schema Registry server cert location (srvcert.pem, srvkey.pem)
*/}}
{{- define "eric-oss-schema-registry-sr.server-cert-directory" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/server-cert
{{- end -}}

{{/*
Kafka client cert location (kfclientcert.pem, kfclientkey.pem)
*/}}
{{- define "eric-oss-schema-registry-sr.kafka-client-cert-directory" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/kafka-client-cert
{{- end -}}

{{/*
JMX Exporter client cert location (jmxclientcert.pem, jmxclientkey.pem)
*/}}
{{- define "eric-oss-schema-registry-sr.jmx-exporter-client-cert-directory" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/jmx-exporter-client-cert
{{- end -}}

{{/*
Schema Registry keystore file name
*/}}
{{- define "eric-oss-schema-registry-sr.server-keystore-file" -}}
server-keystore.p12
{{- end -}}

{{/*
Kafka client keystore file name
*/}}
{{- define "eric-oss-schema-registry-sr.kafka-client-keystore-file" -}}
kafka-client-keystore.p12
{{- end -}}

{{/*
Schema Registry server keystore file path
*/}}
{{- define "eric-oss-schema-registry-sr.server-keystore-file-path" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/{{ template "eric-oss-schema-registry-sr.server-keystore-file" . }}
{{- end -}}

{{/*
Kafka client keystore file path
*/}}
{{- define "eric-oss-schema-registry-sr.kafka-client-keystore-file-path" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/{{ template "eric-oss-schema-registry-sr.kafka-client-keystore-file" . }}
{{- end -}}

{{/*
SSL server truststore file name
*/}}
{{- define "eric-oss-schema-registry-sr.server-truststore-file" -}}
server-truststore.p12
{{- end -}}

{{/*
SSL client truststore file name
*/}}
{{- define "eric-oss-schema-registry-sr.kafka-client-truststore-file" -}}
kafka-client-truststore.p12
{{- end -}}

{{/*
SSL server truststore file path
*/}}
{{- define "eric-oss-schema-registry-sr.server-truststore-file-path" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/{{ template "eric-oss-schema-registry-sr.server-truststore-file" . }}
{{- end -}}

{{/*
Kafka client truststore filepath
*/}}
{{- define "eric-oss-schema-registry-sr.kafka-client-truststore-file-path" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/{{ template "eric-oss-schema-registry-sr.kafka-client-truststore-file" . }}
{{- end -}}

{{/*
JMX Exporter client keystore file name
*/}}
{{- define "eric-oss-schema-registry-sr.jmx-exporter-client-keystore-file" -}}
jmx-exporter-client-keystore.p12
{{- end -}}

{{/*
JMX Exporter client keystore file path
*/}}
{{- define "eric-oss-schema-registry-sr.jmx-exporter-client-keystore-file-path" -}}
{{ template "eric-oss-schema-registry-sr.secrets-directory" . }}/{{ template "eric-oss-schema-registry-sr.jmx-exporter-client-keystore-file" . }}
{{- end -}}

{{/*
Certificate store (keystore, truststore) password
*/}}
{{- define "eric-oss-schema-registry-sr.jks-password" -}}
ZXJpYy1vc3Mtc2NoZW1hLXJlZ2lzdHJ5LXNy
{{- end -}}

{{/*
Requirement for the Schema Registry clients to authenticate themselves.
*/}}
{{- define "eric-oss-schema-registry-sr.client-authentication" -}}
{{- if eq .Values.service.endpoints.schemaregistry.tls.verifyClientCertificate "optional" -}}
REQUESTED
{{- else -}}
{{- .Values.service.endpoints.schemaregistry.tls.verifyClientCertificate | upper -}}
{{- end -}}
{{- end -}}

{{/*
TLS communication setting between SR and JMX Exporter
*/}}
{{- define "eric-oss-schema-registry-sr.jmx-exporter-tls" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{- if and .Values.jmx.enabled $global.security.tls.enabled (eq .Values.service.endpoints.jmx.tls.enforced "required") -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Requirement for the JMX client to authenticate itself.
*/}}
{{- define "eric-oss-schema-registry-sr.jmx-exporter-client-authentication" -}}
{{- if eq .Values.service.endpoints.jmx.tls.verifyClientCertificate "optional" -}}
false
{{- else -}}
true
{{- end -}}
{{- end -}}

{{/*
Schema Registry Monitor JKS livenessProbe & readinessProbe
*/}}
{{- define "eric-oss-schema-registry-sr.monitor-jks-probe" -}}
FILES=( {{ template "eric-oss-schema-registry-sr.server-keystore-file-path" . }}
        {{ template "eric-oss-schema-registry-sr.server-truststore-file-path" . }}
        {{ template "eric-oss-schema-registry-sr.kafka-client-keystore-file-path" . }}
        {{ template "eric-oss-schema-registry-sr.kafka-client-truststore-file-path" . }}
        {{- if eq (include "eric-oss-schema-registry-sr.jmx-exporter-tls" .) "true" }}
        {{ template "eric-oss-schema-registry-sr.jmx-exporter-client-keystore-file-path" . }}
        {{ template "eric-oss-schema-registry-sr.server-keystore-file-path" . }}
        {{- end }} )
for file in ${FILES[@]}; do
  if [ ! -f "$file" ]; then
    echo $file does not exist.
    exit 1
  fi
done
exit 0
{{- end }}

{{- define "eric-oss-schema-registry-sr.jmx-opts" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{- if .Values.jmx.enabled -}}
  {{- print " -Dcom.sun.management.jmxremote" -}}
  {{- print " -Dcom.sun.management.jmxremote.authenticate=false" -}}
  {{- print " -Djava.rmi.server.hostname=" .Values.jmx.hostName -}}
  {{- print " -Dcom.sun.management.jmxremote.local.only=false" -}}
  {{- print " -Dcom.sun.management.jmxremote.rmi.port=" .Values.jmx.destPort -}}
  {{- print " -Dcom.sun.management.jmxremote.port=" .Values.jmx.destPort -}}
  {{- if eq (include "eric-oss-schema-registry-sr.jmx-exporter-tls" .) "true" }}
    {{- print " -Dcom.sun.management.jmxremote.ssl=true" -}}
    {{- print " -Djavax.net.ssl.keyStore.type=pkcs12" -}}
    {{- print " -Djavax.net.ssl.keyStore=" (include "eric-oss-schema-registry-sr.server-keystore-file-path" .) -}}
    {{- print " -Djavax.net.ssl.keyStorePassword=" (include "eric-oss-schema-registry-sr.jks-password" .) -}}
    {{- print " -Djavax.net.ssl.trustStore.type=pkcs12" -}}
    {{- print " -Djavax.net.ssl.trustStore=" (include "eric-oss-schema-registry-sr.jmx-exporter-client-keystore-file-path" .) -}}
    {{- print " -Djavax.net.ssl.trustStorePassword=" (include "eric-oss-schema-registry-sr.jks-password" .) -}}
    {{- print " -Dcom.sun.management.jmxremote.ssl.need.client.auth=" (include "eric-oss-schema-registry-sr.jmx-exporter-client-authentication" .) -}}
    {{- print " -Dcom.sun.management.jmxremote.registry.ssl=true" -}}
  {{- else -}}
    {{- print " -Dcom.sun.management.jmxremote.ssl=false" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
JVM options used by JMX exporter
The unconditional com.sun.management.jmxremote.disabled option is a custom-made placeholder, ignored by JVM. Its purpose is disabling the exporter's JMX monitoring.
*/}}
{{- define "eric-oss-schema-registry-sr.jmx-exporter-jmx-opts" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{- print "-Dcom.sun.management.jmxremote.disabled" }}
{{- if eq (include "eric-oss-schema-registry-sr.jmx-exporter-tls" .) "true" }}
  {{- print " -Djavax.net.ssl.keyStoreType=pkcs12" }}
  {{- print " -Djavax.net.ssl.keyStore=" (include "eric-oss-schema-registry-sr.jmx-exporter-client-keystore-file-path" .) }}
  {{- print " -Djavax.net.ssl.keyStorePassword=" (include "eric-oss-schema-registry-sr.jks-password" .) }}
  {{- print " -Djavax.net.ssl.trustStoreType=pkcs12" }}
  {{- print " -Djavax.net.ssl.trustStore=" (include "eric-oss-schema-registry-sr.server-keystore-file-path" .) }}
  {{- print " -Djavax.net.ssl.trustStorePassword=" (include "eric-oss-schema-registry-sr.jks-password" .) }}
  {{- print " -Dcom.sun.management.jmxremote.registry.ssl=true" }}
{{- end -}}
{{- end -}}

{{/*
check global.security.tls.enabled
*/}}
{{- define "eric-oss-schema-registry-sr.global-security-tls-enabled" -}}
{{- if  .Values.global -}}
  {{- if  .Values.global.security -}}
    {{- if  .Values.global.security.tls -}}
      {{- .Values.global.security.tls.enabled | toString -}}
    {{- else -}}
      {{- "false" -}}
    {{- end -}}
  {{- else -}}
    {{- "false" -}}
  {{- end -}}
{{- else -}}
  {{- "false" -}}
{{- end -}}
{{- end -}}
 
{{/*
DR-D470217-007-AD This helper defines whether this service enter the Service Mesh or not.
*/}}
{{- define "eric-oss-schema-registry-sr.service-mesh-enabled" }}
  {{- $globalMeshEnabled := "false" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.serviceMesh -}}
        {{- $globalMeshEnabled = .Values.global.serviceMesh.enabled -}}
    {{- end -}}
  {{- end -}}
  {{- $globalMeshEnabled -}}
{{- end -}}
 
 
{{/*
DR-D470217-011 This helper defines the annotation which bring the service into the mesh.
*/}}
{{- define "eric-oss-schema-registry-sr.service-mesh-inject" }}
{{- if eq (include "eric-oss-schema-registry-sr.service-mesh-enabled" .) "true" }}
sidecar.istio.io/inject: "true"
{{- else -}}
sidecar.istio.io/inject: "false"
{{- end -}}
{{- end -}}
 
{{/*
GL-D470217-080-AD
This helper captures the service mesh version from the integration chart to
annotate the workloads so they are redeployed in case of service mesh upgrade.
*/}}
{{- define "eric-oss-schema-registry-sr.service-mesh-version" }}
{{- if eq (include "eric-oss-schema-registry-sr.service-mesh-enabled" .) "true" }}
  {{- if .Values.global.serviceMesh -}}
    {{- if .Values.global.serviceMesh.annotations -}}
      {{ .Values.global.serviceMesh.annotations | toYaml }}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define kafka bootstrap server
*/}}
{{- define "eric-oss-schema-registry-sr.kafka-bootstrap-server" -}}
{{- $kafkaBootstrapServer := "" -}}
{{- $serviceMesh := ( include "eric-oss-schema-registry-sr.service-mesh-enabled" . ) -}}
{{- $tls := ( include "eric-oss-schema-registry-sr.global-security-tls-enabled" . ) -}}
{{- if and (eq $serviceMesh "true") (eq $tls "true") -}}
    {{- $kafkaBootstrapServer = .Values.messaging.kafka.bootstrapServersTls -}}
{{ else }}
    {{- $kafkaBootstrapServer = .Values.messaging.kafka.bootstrapServers -}}
{{ end }}
{{- print $kafkaBootstrapServer -}}
{{- end -}}


{{/*
This helper defines the annotation for define service mesh volume
*/}}
{{- define "eric-oss-schema-registry-sr.service-mesh-volume" }}
{{- if and (eq (include "eric-oss-schema-registry-sr.service-mesh-enabled" .) "true") (eq (include "eric-oss-schema-registry-sr.global-security-tls-enabled" .) "true") (eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "false") }}
sidecar.istio.io/userVolume: '{"{{ include "eric-oss-schema-registry-sr.name" . }}-certs-tls":{"secret":{"secretName":"{{ include "eric-oss-schema-registry-sr.name" . }}-secret","optional":true}},"{{ include "eric-oss-schema-registry-sr.name" . }}-certs-ca-tls":{"secret":{"secretName":"eric-sec-sip-tls-trusted-root-cert"}}}'
sidecar.istio.io/userVolumeMount: '{"{{ include "eric-oss-schema-registry-sr.name" . }}-certs-tls":{"mountPath":"/etc/istio/tls/eric-oss-dmm-kf-op-sz-kafka-bootstrap/","readOnly":true},"{{ include "eric-oss-schema-registry-sr.name" . }}-certs-ca-tls":{"mountPath":"/etc/istio/tls-ca","readOnly":true}}'
{{ end }}
{{- if and (eq (include "eric-oss-schema-registry-sr.service-mesh-enabled" .) "true") (eq (include "eric-oss-schema-registry-sr.global-security-tls-enabled" .) "true") (eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true") (eq (include "eric-oss-schema-registry-sr.osmService-aas-enabled" .) "true") (eq (include "eric-oss-schema-registry-sr.osmService-ais-enabled" .) "true") (eq (include "eric-oss-schema-registry-sr.osmService-csac-enabled" .) "true") }}
sidecar.istio.io/userVolume: '{"{{ include "eric-oss-schema-registry-sr.name" . }}-certs-tls":{"secret":{"secretName":"{{ include "eric-oss-schema-registry-sr.name" . }}-secret","optional":true}},"{{ include "eric-oss-schema-registry-sr.name" . }}-certs-ca-tls":{"secret":{"secretName":"eric-sec-sip-tls-trusted-root-cert"}},
"{{ include "eric-oss-schema-registry-sr.name" . }}-osm-service-aas-certs-tls":{"secret":{"secretName":"{{ include "eric-oss-schema-registry-sr.name" . }}-{{ include "eric-oss-schema-registry-sr.osmService-aas-name" . }}-secret","optional":true}},"{{ include "eric-oss-schema-registry-sr.name" . }}-osm-service-ais-certs-tls":{"secret":{"secretName":"{{ include "eric-oss-schema-registry-sr.name" . }}-{{ include "eric-oss-schema-registry-sr.osmService-ais-name" . }}-secret","optional":true}},"{{ include "eric-oss-schema-registry-sr.name" . }}-osm-service-csac-certs-tls":{"secret":{"secretName":"{{ include "eric-oss-schema-registry-sr.name" . }}-{{ include "eric-oss-schema-registry-sr.osmService-csac-name" . }}-secret","optional":true}}}'
sidecar.istio.io/userVolumeMount: '{"{{ include "eric-oss-schema-registry-sr.name" . }}-certs-tls":{"mountPath":"/etc/istio/tls/eric-oss-dmm-kf-op-sz-kafka-bootstrap/","readOnly":true},"{{ include "eric-oss-schema-registry-sr.name" . }}-certs-ca-tls":{"mountPath":"/etc/istio/tls-ca","readOnly":true},
"{{ include "eric-oss-schema-registry-sr.name" . }}-osm-service-aas-certs-tls":{"mountPath":"/etc/istio/tls/{{ include "eric-oss-schema-registry-sr.osmService-aas-name" . }}/","readOnly":true},"{{ include "eric-oss-schema-registry-sr.name" . }}-osm-service-ais-certs-tls":{"mountPath":"/etc/istio/tls/{{ include "eric-oss-schema-registry-sr.osmService-ais-name" . }}/","readOnly":true},"{{ include "eric-oss-schema-registry-sr.name" . }}-osm-service-csac-certs-tls":{"mountPath":"/etc/istio/tls/{{ include "eric-oss-schema-registry-sr.osmService-csac-name" . }}/","readOnly":true}}'
{{ end }}
{{- end -}}


{{/*
This helper defines which out-mesh services will be reached by this one.
*/}}
{{- define "eric-oss-schema-registry-sr.service-mesh-ism2osm-labels" }}
{{- if eq (include "eric-oss-schema-registry-sr.service-mesh-enabled" .) "true" }}
  {{- if eq (include "eric-oss-schema-registry-sr.global-security-tls-enabled" .) "true" }}
eric-oss-dmm-kf-op-sz-kafka-ism-access: "true"
  {{- end }}
{{- end -}}
{{- end -}}

{{/*
Define listener port mapping.
*/}}
{{- define "eric-oss-schema-registry-sr.sm-listener" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
    http://0.0.0.0:{{ .Values.security.plaintext.schemaregistry.port }}
{{- end -}}


{{- define "eric-oss-schema-registry-sr.sm-jmx-opts" -}}
{{- $global := fromJson (include "eric-oss-schema-registry-sr.global" .) -}}
{{- if .Values.jmx.enabled -}}
  {{- print " -Dcom.sun.management.jmxremote" -}}
  {{- print " -Dcom.sun.management.jmxremote.authenticate=false" -}}
  {{- print " -Djava.rmi.server.hostname=" .Values.jmx.hostName -}}
  {{- print " -Dcom.sun.management.jmxremote.local.only=false" -}}
  {{- print " -Dcom.sun.management.jmxremote.rmi.port=" .Values.jmx.destPort -}}
  {{- print " -Dcom.sun.management.jmxremote.port=" .Values.jmx.destPort -}}
  {{- print " -Dcom.sun.management.jmxremote.ssl=false" -}}
{{- end -}}
{{- end -}}

{{/*
    Define supplementalGroups (DR-D1123-135)
*/}}
{{- define "eric-oss-schema-registry-sr.supplementalGroups" -}}
  {{- $globalGroups := (list) -}}
  {{- if ( (((.Values).global).podSecurityContext).supplementalGroups) }}
    {{- $globalGroups = .Values.global.podSecurityContext.supplementalGroups -}}
  {{- end -}}
  {{- $localGroups := (list) -}}
  {{- if ( ((.Values).podSecurityContext).supplementalGroups) -}}
    {{- $localGroups = .Values.podSecurityContext.supplementalGroups -}}
  {{- end -}}
  {{- $mergedGroups := (list) -}}
  {{- if $globalGroups -}}
    {{- $mergedGroups = $globalGroups -}}
  {{- end -}}
  {{- if $localGroups -}}
    {{- $mergedGroups = concat $globalGroups $localGroups | uniq -}}
  {{- end -}}
  {{- if $mergedGroups -}}
    supplementalGroups: {{- toYaml $mergedGroups | nindent 8 -}}
  {{- end -}}
  {{- /*Do nothing if both global and local groups are not set */ -}}
{{- end -}}

{{/*
Return the fsgroup set via global parameter if it's set, otherwise 10000
*/}}
{{- define "eric-oss-schema-registry-sr.fsGroup.coordinated" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.fsGroup -}}
      {{- if .Values.global.fsGroup.manual -}}
        {{ .Values.global.fsGroup.manual }}
      {{- else -}}
        {{- if .Values.global.fsGroup.namespace -}}
          # The 'default' defined in the Security Policy will be used.
        {{- else -}}
          10000
      {{- end -}}
    {{- end -}}
  {{- else -}}
    10000
  {{- end -}}
  {{- else -}}
    10000
  {{- end -}}
{{- end -}}


{{/*
Define logRedirect
Mapping between log.outputs and logshipper redirect parameter
*/}}
{{- define "eric-oss-schema-registry-sr.logRedirect" -}}
{{- $logRedirect := "file" -}}
{{- if .Values.log -}}
  {{- if .Values.log.outputs -}}
    {{- if (and (has "stream" .Values.log.outputs) (has "stdout" .Values.log.outputs)) -}}
      {{- $logRedirect = "all" -}}
    {{- else if has "stream" .Values.log.outputs -}}
      {{- $logRedirect = "file" -}}
    {{- else -}}
      {{- $logRedirect = "stdout" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- print $logRedirect -}}
{{- end -}}

{{/*
Seccomp profile section (DR-1123-128)
*/}}
{{- define "eric-oss-schema-registry-sr.seccomp-profile" }}
    {{- if .Values.seccompProfile }}
      {{- if .Values.seccompProfile.type }}
          {{- if eq .Values.seccompProfile.type "Localhost" }}
              {{- if .Values.seccompProfile.localhostProfile }}
seccompProfile:
  type: {{ .Values.seccompProfile.type }}
  localhostProfile: {{ .Values.seccompProfile.localhostProfile }}
            {{- end }}
          {{- else }}
seccompProfile:
  type: {{ .Values.seccompProfile.type }}
          {{- end }}
        {{- end }}
      {{- end }}
{{- end }}

{{/*
Create prometheus info
*/}}
{{- define "eric-oss-schema-registry-sr.prometheus-config" -}}
prometheus.io/port: {{ .Values.jmx.servicePort | quote }}
prometheus.io/scrape: "true"
{{- if .Values.enableNewScrapePattern }}
prometheus.io/scrape-role: "pod"
prometheus.io/scrape-interval: "15s"
prometheus.io/path: ""
{{- end }}
{{- end -}}

{{/*
Merged annotations adding  prometheus to Default
*/}}
{{- define "eric-oss-schema-registry-sr.prometheus" -}}
  {{- if .Values.jmx.enabled }}
    {{- $merged := include "eric-oss-schema-registry-sr.annotations" . | fromYaml -}}
    {{- $prometheus := include "eric-oss-schema-registry-sr.prometheus-config" . | fromYaml -}}
    {{- include "eric-oss-schema-registry-sr.mergeAnnotations" (dict "location" .Template.Name "sources" (list $merged $prometheus)) | trim }}
  {{- else}}
    {{- include "eric-oss-schema-registry-sr.annotations" . }}
  {{- end }}
{{- end -}}

{{/*
 DR-D1123-134
This helper defines whether this service has to bind security policies to the service account using role binding if defined.
It enters only if security policies are defined at global.
*/}}
{{- define "eric-oss-schema-registry-sr.security-policies-defined" }}
  {{- $globalSecurityPoliciesDefined := "false" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.securityPolicy -}}
      {{- if ne .Values.global.securityPolicy.rolekind "" }}
        {{- $globalSecurityPoliciesDefined = "true" -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $globalSecurityPoliciesDefined -}}
{{- end -}}

{{- define "eric-oss-schema-registry-sr.securityPolicy.rolebinding.name" }}
  {{- if eq (include "eric-oss-schema-registry-sr.security-policies-defined" .) "true" }}
    {{- if eq .Values.global.securityPolicy.rolekind "ClusterRole" }}
      {{ include "eric-oss-schema-registry-sr.name" . }}-sa-c-{{ .Values.securityPolicy.rolename }}-sp
    {{- end -}}
    {{- if eq .Values.global.securityPolicy.rolekind "Role" }}
      {{ include "eric-oss-schema-registry-sr.name" . }}-sa-r-{{ .Values.securityPolicy.rolename }}-sp
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
This helper defines whether this service is in ESOA namespace or not.
*/}}
{{- define "eric-oss-schema-registry-sr.osm2ism-enabled" }}
  {{- $osm2ismEnabled := "false" -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.enabled -}}
        {{- $osm2ismEnabled = .Values.osm2ism.enabled -}}
    {{- end -}}
  {{- end -}}
  {{- $osm2ismEnabled -}}
{{- end -}}

{{/*
This helper checks osm2ism is enabled for the out-mesh service Assurance Augmentation
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-aas-enabled" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $serviceAasEnabled := false -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService.serviceAAS -}}
      {{- $serviceAasEnabled = .Values.osm2ism.outMeshService.serviceAAS.enabled -}}
    {{- end -}}
  {{- end -}}
  {{- $serviceAasEnabled -}}
{{- end -}}
{{- end -}}

{{/*
This helper captures the repo name of out-mesh service Assurance Augmentation,
which wants to communicate with this service.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-aas-name" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $outMeshServiceName := "" -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService.serviceAAS -}}
      {{- if eq (include "eric-oss-schema-registry-sr.osmService-aas-enabled" .) "true" }}
          {{- $outMeshServiceName = .Values.osm2ism.outMeshService.serviceAAS.name | trunc 30 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $outMeshServiceName -}}
{{- end -}}
{{- end -}}

{{/*
This helper checks the issuer reference is enabled for the out-mesh service Assurance Augmentation.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-aas-issuerRef-enabled" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $osmIntermediateCaEnabled := false -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService.serviceAAS -}}
      {{- if eq (include "eric-oss-schema-registry-sr.osmService-aas-enabled" .) "true" }}
        {{- if .Values.osm2ism.outMeshService.serviceAAS.intermediateCA -}}
          {{- if .Values.osm2ism.outMeshService.serviceAAS.intermediateCA.enabled -}}
              {{- $osmIntermediateCaEnabled = .Values.osm2ism.outMeshService.serviceAAS.intermediateCA.enabled -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $osmIntermediateCaEnabled -}}
{{- end -}}
{{- end -}}

{{/*
This helper captures the issuer reference of the out-mesh service Assurance Augmentation, that wants to communicate with this service.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-aas-issuerRef" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $outMeshServiceIssuerRef := "" -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService -}}
      {{- if .Values.osm2ism.outMeshService.serviceAAS -}}
        {{- if eq (include "eric-oss-schema-registry-sr.osmService-aas-enabled" .) "true" }}
          {{- if .Values.osm2ism.outMeshService.serviceAAS.intermediateCA -}}
            {{- if .Values.osm2ism.outMeshService.serviceAAS.intermediateCA.enabled -}}
                {{- $outMeshServiceIssuerRef = .Values.osm2ism.outMeshService.serviceAAS.intermediateCA.name -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $outMeshServiceIssuerRef -}}
{{- end -}}
{{- end -}}

{{/*
This helper checks osm2ism is enabled for the out-mesh service Assurance Indexer.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-ais-enabled" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $serviceAisEnabled := false -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService.serviceAIS -}}
      {{- $serviceAisEnabled = .Values.osm2ism.outMeshService.serviceAIS.enabled -}}
    {{- end -}}
  {{- end -}}
  {{- $serviceAisEnabled -}}
{{- end -}}
{{- end -}}

{{/*
This helper captures the repo name of out-mesh service Assurance Indexer,
which wants to communicate with this service.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-ais-name" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $outMeshServiceAisName := "" -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService.serviceAIS -}}
      {{- if eq (include "eric-oss-schema-registry-sr.osmService-ais-enabled" .) "true" }}
          {{- $outMeshServiceAisName = .Values.osm2ism.outMeshService.serviceAIS.name | trunc 30 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $outMeshServiceAisName -}}
{{- end -}}
{{- end -}}

{{/*
This helper checks the issuer reference is enabled for the out-mesh service Assurance Indexer.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-ais-issuerRef-enabled" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $osmAisIntermediateCaEnabled := false -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService.serviceAIS -}}
      {{- if eq (include "eric-oss-schema-registry-sr.osmService-ais-enabled" .) "true" }}
        {{- if .Values.osm2ism.outMeshService.serviceAIS.intermediateCA -}}
          {{- if .Values.osm2ism.outMeshService.serviceAIS.intermediateCA.enabled -}}
              {{- $osmAisIntermediateCaEnabled = .Values.osm2ism.outMeshService.serviceAIS.intermediateCA.enabled -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $osmAisIntermediateCaEnabled -}}
{{- end -}}
{{- end -}}

{{/*
This helper captures the issuer reference of the out-mesh service Assurance Indexer, that wants to communicate with this service.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-ais-issuerRef" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $outMeshServiceAisIssuerRef := "" -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService -}}
      {{- if .Values.osm2ism.outMeshService.serviceAIS -}}
        {{- if eq (include "eric-oss-schema-registry-sr.osmService-ais-enabled" .) "true" }}
          {{- if .Values.osm2ism.outMeshService.serviceAIS.intermediateCA -}}
            {{- if eq (include "eric-oss-schema-registry-sr.osmService-ais-issuerRef-enabled" .) "true" }}
                {{- $outMeshServiceAisIssuerRef = .Values.osm2ism.outMeshService.serviceAIS.intermediateCA.name -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $outMeshServiceAisIssuerRef -}}
{{- end -}}
{{- end -}}

{{/*
This helper checks osm2ism is enabled for the out-mesh service CSAC.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-csac-enabled" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $serviceCsacEnabled := false -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService.serviceCSAC -}}
      {{- $serviceCsacEnabled = .Values.osm2ism.outMeshService.serviceCSAC.enabled -}}
    {{- end -}}
  {{- end -}}
  {{- $serviceCsacEnabled -}}
{{- end -}}
{{- end -}}

{{/*
This helper captures the repo name of out-mesh service CSAC,
which wants to communicate with this service.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-csac-name" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $outMeshServiceCsacName := "" -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService.serviceCSAC -}}
      {{- if eq (include "eric-oss-schema-registry-sr.osmService-csac-enabled" .) "true" }}
          {{- $outMeshServiceCsacName = .Values.osm2ism.outMeshService.serviceCSAC.name | trunc 30 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $outMeshServiceCsacName -}}
{{- end -}}
{{- end -}}

{{/*
This helper checks the issuer reference is enabled for the out-mesh service CSAC.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-csac-issuerRef-enabled" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $osmCsacIntermediateCaEnabled := false -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService.serviceCSAC -}}
      {{- if eq (include "eric-oss-schema-registry-sr.osmService-csac-enabled" .) "true" }}
        {{- if .Values.osm2ism.outMeshService.serviceCSAC.intermediateCA -}}
          {{- if .Values.osm2ism.outMeshService.serviceCSAC.intermediateCA.enabled -}}
              {{- $osmCsacIntermediateCaEnabled = .Values.osm2ism.outMeshService.serviceCSAC.intermediateCA.enabled -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $osmCsacIntermediateCaEnabled -}}
{{- end -}}
{{- end -}}

{{/*
This helper captures the issuer reference of the out-mesh service CSAC, that wants to communicate with this service.
*/}}
{{- define "eric-oss-schema-registry-sr.osmService-csac-issuerRef" }}
{{- if eq (include "eric-oss-schema-registry-sr.osm2ism-enabled" .) "true" }}
  {{- $outMeshServiceCsacIssuerRef := "" -}}
  {{- if .Values.osm2ism -}}
    {{- if .Values.osm2ism.outMeshService -}}
      {{- if .Values.osm2ism.outMeshService.serviceCSAC -}}
        {{- if eq (include "eric-oss-schema-registry-sr.osmService-csac-enabled" .) "true" }}
          {{- if .Values.osm2ism.outMeshService.serviceCSAC.intermediateCA -}}
            {{- if eq (include "eric-oss-schema-registry-sr.osmService-csac-issuerRef-enabled" .) "true" }}
                {{- $outMeshServiceCsacIssuerRef = .Values.osm2ism.outMeshService.serviceCSAC.intermediateCA.name -}}
            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $outMeshServiceCsacIssuerRef -}}
{{- end -}}
{{- end -}}

{{/*
Define JVM heap size (DR-D1126-011)
*/}}
{{- define "eric-oss-schema-registry-sr.jvmHeapSettings" -}}
  {{- if and (.Values.enableJvm) (eq .Values.enableJvm true) }}
    {{- $initRAM := "" -}}
    {{- $maxRAM := "" -}}
    {{/*
       ramLimit is set by default to 1.0, this is if the service is set to use anything less than M/Mi
       Rather than trying to cover each type of notation,
       if a user is using anything less than M/Mi then the assumption is its less than the cutoff of 1.3GB
       */}}
    {{- $ramLimit := 1.0 -}}
    {{- $ramComparison := 1.3 -}}

    {{- if (index .Values "resources" "schemaregistry" "jvm") -}}
        {{- if (index .Values "resources" "schemaregistry" "jvm" "initialMemoryAllocationPercentage") -}}
            {{- $initRAM = index .Values "resources" "schemaregistry" "jvm" "initialMemoryAllocationPercentage" | float64 -}}
            {{- $initRAM = printf "-XX:InitialRAMPercentage=%f" $initRAM -}}
        {{- else -}}
            {{- fail "initialMemoryAllocationPercentage not set" -}}
        {{- end -}}
        {{- if and (index .Values "resources" "schemaregistry" "jvm" "smallMemoryAllocationMaxPercentage") (index .Values "resources" "schemaregistry" "jvm" "largeMemoryAllocationMaxPercentage") -}}
            {{- if lt $ramLimit $ramComparison -}}
                {{- $maxRAM =index .Values "resources" "schemaregistry" "jvm" "smallMemoryAllocationMaxPercentage" | float64 -}}
                {{- $maxRAM = printf "-XX:MaxRAMPercentage=%f" $maxRAM -}}
            {{- else -}}
                {{- $maxRAM = index .Values "resources" "schemaregistry" "jvm" "largeMemoryAllocationMaxPercentage" | float64 -}}
                {{- $maxRAM = printf "-XX:MaxRAMPercentage=%f" $maxRAM -}}
            {{- end -}}
        {{- else -}}
            {{- fail "smallMemoryAllocationMaxPercentage | largeMemoryAllocationMaxPercentage not set" -}}
        {{- end -}}
    {{- else -}}
        {{- fail "jvm heap percentages are not set" -}}
    {{- end -}}
  {{- printf "%s %s" $initRAM $maxRAM -}}
  {{- end -}}
{{- end -}}

