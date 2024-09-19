{{/*
USAGE:
{{ include "mc-chart.pvc" (dict "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}

{{- define "mc-chart.pvc" -}}
{{- $context := .context -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- if and $context.Values.persistence.enabled (not $context.Values.persistence.existingClaim) -}}
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ include "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
  {{- if or $context.Values.persistence.annotations $context.Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" (dict "values" (list $context.Values.persistence.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context ) | nindent 4 }}
  {{- end }}
spec:
  accessModes:
  {{- range $context.Values.persistence.accessModes }}
    - {{ . | quote }}
  {{- end }}
  resources:
    requests:
      storage: {{ $context.Values.persistence.size | quote }}
  {{- if $context.Values.persistence.selector }}
  selector: {{- include "common.tplvalues.render" (dict "value" $context.Values.persistence.selector "context" $context) | nindent 4 }}
  {{- end }}
  {{- if $context.Values.persistence.dataSource }}
  dataSource: {{- include "common.tplvalues.render" (dict "value" $context.Values.persistence.dataSource "context" $context) | nindent 4 }}
  {{- end }}
  {{- include "common.storage.class" (dict "persistence" $context.Values.persistence "global" $context.Values.global) | nindent 2 }}
{{- end -}}
{{- end -}}