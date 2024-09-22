{{/*
USAGE:
{{ include "mc-chart.roleBinding" (dict "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}


{{- define "mc-chart.roleBinding" -}}
{{- $context := .context -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- if $context.Values.rbac.create }}
apiVersion: {{ include "common.capabilities.rbac.apiVersion" $context }}
kind: RoleBinding
metadata:
  name: {{ template "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if $context.Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" .Values.commonAnnotations "context" $context ) | nindent 4 }}
  {{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: {{ template "common.names.fullname" $context }}
subjects:
  - kind: ServiceAccount
    name: {{ include "tplHelpers.serviceAccountName" $context }}
    namespace: {{ include "common.names.namespace" $context | quote }}
{{- end }}
{{- end }}