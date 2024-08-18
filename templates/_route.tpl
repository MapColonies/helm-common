{{/*
USAGE:
{{ include "mc-chart.route" (dict "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}

{{- define "mc-chart.route" -}}
{{- $context := .context }}
{{- $MAIN_OBJECT_BLOCK := get $context.Values .MAIN_OBJECT_BLOCK -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- if $context.Values.route.enabled }}
apiVersion: {{ include "common.capabilities.route.apiVersion" $context }}
kind: Route
metadata:
  name: {{ template "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if or $context.Values.route.annotations $context.Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" (dict "values" (list $context.Values.route.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context ) | nindent 4 }}
    {{- if $context.Values.route.timeout.enabled }}
    haproxy.router.openshift.io/timeout: {{ $context.Values.route.timeout.duration }}
    {{- end }}
  {{- end }}
spec:
  {{- if $context.Values.route.hostname }}
  host: {{ $context.Values.route.hostname }}
  {{- end }}
  path: {{ $context.Values.route.path | default "/"}}
  to:
    kind: Service
    name: {{ include "common.names.fullname" $context }}
  port:
    targetPort: {{ $MAIN_OBJECT_BLOCK.containerPorts.http }}
  {{- if $context.Values.route.tls.enabled }}
  tls:
    termination: {{ $context.Values.route.tls.termination }}
    insecureEdgeTerminationPolicy: {{ $context.Values.route.tls.insecureEdgeTerminationPolicy }}
    {{- if $context.Values.route.tls.useCerts }}
    {{- include "common.tplvalues.getGlobalObject" (dict "objName" "tlsCertificates" "context" $context) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if $context.Values.route.extraRules }}
  {{- include "common.tplvalues.render" (dict "value" $context.Values.route.extraRules "context" $context) | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}