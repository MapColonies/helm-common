{{/*
USAGE:
{{ include "mc-chart.vpa" (dict "MAIN_OBJECT_BLOCK" $MAIN_OBJECT_BLOCK "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}

{{- define "mc-chart.vpa" -}}
{{- $context := .context -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- $MAIN_OBJECT_BLOCK := get $context.Values .MAIN_OBJECT_BLOCK -}}
{{- if and ($context.Capabilities.APIVersions.Has "autoscaling.k8s.io/v1/VerticalPodAutoscaler") $MAIN_OBJECT_BLOCK.autoscaling.vpa.enabled }}
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: {{ include "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
  {{- if or $MAIN_OBJECT_BLOCK.autoscaling.vpa.annotations $context.Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" ( dict "values" ( list $MAIN_OBJECT_BLOCK.autoscaling.vpa.annotations $context.Values.commonAnnotations ) "context" $context ) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context) | nindent 4 }}
  {{- end }}
spec:
  resourcePolicy:
    containerPolicies:
    - containerName: {{ $MAIN_OBJECT_BLOCK }}
      {{- with $MAIN_OBJECT_BLOCK.autoscaling.vpa.controlledResources }}
      controlledResources:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $MAIN_OBJECT_BLOCK.autoscaling.vpa.maxAllowed }}
      maxAllowed:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $MAIN_OBJECT_BLOCK.autoscaling.vpa.minAllowed }}
      minAllowed:
        {{- toYaml . | nindent 8 }}
      {{- end }}
  targetRef:
    apiVersion: {{ include "common.capabilities.deployment.apiVersion" $context }}
    kind: Deployment
    name: {{ include "common.names.fullname" $context }}
  {{- if $MAIN_OBJECT_BLOCK.autoscaling.vpa.updatePolicy }}
  updatePolicy:
    {{- with $MAIN_OBJECT_BLOCK.autoscaling.vpa.updatePolicy.updateMode }}
    updateMode: {{ . }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end -}}