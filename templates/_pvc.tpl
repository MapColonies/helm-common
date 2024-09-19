{{/*
USAGE:
{{ include "mc-chart.pvc" (dict "COMPONENT_NAME" $COMPONENT_NAME "PERSISTENCE" $PERSISTENCE "context" .) }}
*/}}

{{- define "mc-chart.pvc" -}}
{{- $context := .context -}}
{{- $PERSISTENCE := .PERSISTENCE -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ include "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
  {{- if $context.Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $context.Values.commonAnnotations "context" $context ) | nindent 4 }}
  {{- end }}
spec:
  accessModes:
  {{- range $PERSISTENCE.accessModes }}
    - {{ . | quote }}
  {{- end }}
  resources:
    requests:
      storage: {{ $PERSISTENCE.size | quote }}
  {{- if $PERSISTENCE.selector }}
  selector: {{- include "common.tplvalues.render" (dict "value" $context.Values.persistence.selector "context" $context) | nindent 4 }}
  {{- end }}
  {{- if $PERSISTENCE.dataSource }}
  dataSource: {{- include "common.tplvalues.render" (dict "value" $context.Values.persistence.dataSource "context" $context) | nindent 4 }}
  {{- end }}
  storageClassName: {{ $PERSISTENCE.storageClassName }}
{{- end -}}