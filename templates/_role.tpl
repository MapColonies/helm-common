{{/*
USAGE:
{{ include "mc-chart.role" (dict "context" .) }}
*/}}


{{- define "mc-chart.role" -}}
{{- $context := .context }}
{{- if $context.Values.rbac.create }}
apiVersion: {{ include "common.capabilities.rbac.apiVersion" $context }}
kind: Role
metadata:
  name: {{ template "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if $context.Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $context.Values.commonAnnotations "context" $context ) | nindent 4 }}
  {{- end }}
rules:
  {{- if and (include "common.capabilities.psp.supported" $context) $context.Values.podSecurityPolicy.enabled }}
  - apiGroups:
      - '{{ template "podSecurityPolicy.apiGroup" $context }}'
    resources:
      - 'podsecuritypolicies'
    verbs:
      - 'use'
    resourceNames: [{{ printf "%s-master" (include "common.names.fullname" $context) }}]
  {{- end }}
  {{- if $context.Values.rbac.rules }}
  {{- include "common.tplvalues.render" ( dict "value" $context.Values.rbac.rules "context" $context ) | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}