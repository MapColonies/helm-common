{{/*
USAGE:
{{ include "mc-chart.service" (dict "MAIN_OBJECT_BLOCK" $MAIN_OBJECT_BLOCK "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}

{{- define "mc-chart.service" -}}
{{- $context := .context }}
{{- $MAIN_OBJECT_BLOCK := get $context.Values .MAIN_OBJECT_BLOCK -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
apiVersion: {{ include "common.capabilities.service.apiVersion" $context }}
kind: Service
metadata:
  name: {{ template "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if or $context.Values.service.annotations $context.Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" (dict "values" (list $context.Values.service.annotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context ) | nindent 4 }}
  {{- end }}
spec:
  type: {{ $context.Values.service.type }}
  {{- if and $context.Values.service.clusterIP (eq $context.Values.service.type "ClusterIP") }}
  clusterIP: {{ $context.Values.service.clusterIP }}
  {{- end }}
  {{- if $context.Values.service.sessionAffinity }}
  sessionAffinity: {{ $context.Values.service.sessionAffinity }}
  {{- end }}
  {{- if $context.Values.service.sessionAffinityConfig }}
  sessionAffinityConfig: {{- include "common.tplvalues.render" (dict "value" $context.Values.service.sessionAffinityConfig "context" $context) | nindent 4 }}
  {{- end }}
  {{- if and $context.Values.service.externalTrafficPolicy (or (eq $context.Values.service.type "LoadBalancer") (eq $context.Values.service.type "NodePort")) }}
  externalTrafficPolicy: {{ $context.Values.service.externalTrafficPolicy | quote }}
  {{- end }}
  {{- if and (eq $context.Values.service.type "LoadBalancer") (not (empty $context.Values.service.loadBalancerSourceRanges)) }}
  loadBalancerSourceRanges: {{ $context.Values.service.loadBalancerSourceRanges }}
  {{- end }}
  {{- if and (eq $context.Values.service.type "LoadBalancer") (not (empty $context.Values.service.loadBalancerIP)) }}
  loadBalancerIP: {{ $context.Values.service.loadBalancerIP }}
  {{- end }}
  ports:
    - name: HTTP-MAIN-PORT
      port: {{ $context.Values.service.ports.http }}
      {{- if not (eq $context.Values.service.ports.http $MAIN_OBJECT_BLOCK.containerPorts.http) }}
      targetPort: {{ $MAIN_OBJECT_BLOCK.containerPorts.http }}
      {{- end }}
      protocol: {{ $context.Values.service.protocol }}
      {{- if and (or (eq $context.Values.service.type "NodePort") (eq $context.Values.service.type "LoadBalancer")) (not (empty $context.Values.service.nodePorts.http)) }}
      nodePort: {{ $context.Values.service.nodePorts.http }}
      {{- else if eq $context.Values.service.type "ClusterIP" }}
      nodePort: null
      {{- end }}
    {{- if $context.Values.service.extraPorts }}
    {{- include "common.tplvalues.render" (dict "value" $context.Values.service.extraPorts "context" $) | nindent 4 }}
    {{- end }}
  {{- $podLabels := include "common.tplvalues.merge" (dict "values" (list $MAIN_OBJECT_BLOCK.podLabels $context.Values.commonLabels) "context" $context) | fromYaml }}
  selector: {{- include "common.labels.matchLabels" ( dict "customLabels" $podLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
{{- end }}