{{/*
Template of Backup and Restore Agent(BRAgent) for Schema Registry
*/}}

{{/*
Create BR Agent name
*/}}
{{- define "eric-oss-schema-registry-sr.agentName" -}}
{{ template "eric-oss-schema-registry-sr.name" .}}-agent
{{- end -}}

{{/*
Get bro service name
*/}}
{{- define "eric-oss-schema-registry-sr.broServiceName" -}}
{{- $broServiceName := "eric-ctrl-bro" -}}
{{- if .Values.global -}}
    {{- if .Values.global.adpBR -}}
        {{- if .Values.global.adpBR.broServiceName -}}
            {{- $broServiceName = .Values.global.adpBR.broServiceName -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- print $broServiceName -}}
{{- end -}}

{{/*
Get bro service port
*/}}
{{- define "eric-oss-schema-registry-sr.broGrpcServicePort" -}}
{{- $broGrpcServicePort := "3000" -}}
{{- if .Values.global -}}
    {{- if .Values.global.adpBR -}}
        {{- if .Values.global.adpBR.broGrpcServicePort -}}
            {{- $broGrpcServicePort = .Values.global.adpBR.broGrpcServicePort -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- print $broGrpcServicePort -}}
{{- end -}}

{{- define "eric-oss-schema-registry-sr.agent.standard-labels" -}}
app.kubernetes.io/name: {{ template "eric-oss-schema-registry-sr.name" . }}
app.kubernetes.io/version: {{ template "eric-oss-schema-registry-sr.version" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app: {{ template "eric-oss-schema-registry-sr.agentName" . }}
chart: {{ template "eric-oss-schema-registry-sr.chart" . }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
{{- end -}}

{{/*
Merged labels for Default, which includes Standard and Config
*/}}
{{- define "eric-oss-schema-registry-sr.agent.labels" -}}
  {{- $standard := include "eric-oss-schema-registry-sr.agent.standard-labels" . | fromYaml -}}
  {{- $config := include "eric-oss-schema-registry-sr.config-labels" . | fromYaml -}}
  {{- include "eric-oss-schema-registry-sr.mergeLabels" (dict "location" .Template.Name "sources" (list $standard $config)) | trim }}
  {{- include "eric-oss-schema-registry-sr.agent.selectorLabels" . | nindent 0 }}
{{- end -}}

{{/*
Get bro service brLabelKey
*/}}
{{- define "eric-oss-schema-registry-sr.brLabelKey" -}}
{{- $brLabelKey := "adpbrlabelkey" -}}
{{- if .Values.global -}}
    {{- if .Values.global.adpBR -}}
        {{- if .Values.global.adpBR.brLabelKey -}}
            {{- $brLabelKey = .Values.global.adpBR.brLabelKey -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- print $brLabelKey -}}
{{- end -}}

{{/*
Agent Selector labels. DR-D470218-004-AD
*/}}
{{- define "eric-oss-schema-registry-sr.agent.selectorLabels" }}
{{- template "eric-oss-schema-registry-sr.brLabelKey" . -}}: {{ template "eric-oss-schema-registry-sr.name" . }}
{{- end -}}

{{/*
Semi-colon separated list of backup types
*/}}
{{- define "eric-oss-schema-registry-sr.agent.backupTypes" }}
{{- range $i, $e := .Values.brAgent.backupTypeList -}}
{{- if eq $i 0 -}}{{- printf " " -}}{{- else -}}{{- printf ";" -}}{{- end -}}{{- . -}}
{{- end -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and service level - brAgent.
*/}}
{{- define "eric-oss-schema-registry-sr.brAgentNodeSelector" -}}
{{- $globalValue := (dict) -}}
{{- if .Values.global -}}
    {{- if .Values.global.nodeSelector -}}
         {{- $globalValue = .Values.global.nodeSelector -}}
    {{- end -}}
{{- end -}}
{{- if .Values.nodeSelector.brAgent -}}
  {{- range $key, $localValue := .Values.nodeSelector.brAgent -}}
    {{- if hasKey $globalValue $key -}}
         {{- $Value := index $globalValue $key -}}
         {{- if ne $Value $localValue -}}
           {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
         {{- end -}}
     {{- end -}}
    {{- end -}}
    nodeSelector: {{- toYaml (merge $globalValue .Values.nodeSelector.brAgent) | trim | nindent 2 -}}
{{- else -}}
  {{- if not ( empty $globalValue ) -}}
    nodeSelector: {{- toYaml $globalValue | trim | nindent 2 -}}
  {{- end -}}
{{- end -}}
{{- end -}}
