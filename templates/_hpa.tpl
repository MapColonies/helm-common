{{/*
USAGE:
{{ include "mc-chart.hpa" (dict "MAIN_OBJECT_BLOCK" $MAIN_OBJECT_BLOCK "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}

{{- define "mc-chart.hpa" -}}
{{- $context := .context -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- $MAIN_OBJECT_BLOCK := get $context.Values .MAIN_OBJECT_BLOCK -}}
{{- if $MAIN_OBJECT_BLOCK.autoscaling.hpa.enabled }}
apiVersion: {{ include "common.capabilities.hpa.apiVersion" . }}
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
  {{- if $context.Values.commonAnnotations }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $context.Values.commonAnnotations "context" $context ) | nindent 4 }}
  {{- end }}
spec:
  scaleTargetRef:
    apiVersion: {{ include "common.capabilities.deployment.apiVersion" $context }}
    kind: Deployment
    name: {{ include "common.names.fullname" $context }}
  minReplicas: {{ $MAIN_OBJECT_BLOCK.autoscaling.hpa.minReplicas }}
  maxReplicas: {{ $MAIN_OBJECT_BLOCK.autoscaling.hpa.maxReplicas }}
  metrics:
    {{- if $MAIN_OBJECT_BLOCK.autoscaling.hpa.targetMemory }}
    - type: Resource
      resource:
        name: memory
        {{- if semverCompare "<1.23-0" (include "common.capabilities.kubeVersion" $context) }}
        targetAverageUtilization: {{ $MAIN_OBJECT_BLOCK.autoscaling.hpa.targetMemory  }}
        {{- else }}
        target:
          type: Utilization
          averageUtilization: {{ $context.Values.worker.autoscaling.hpa.targetMemory }}
        {{- end }}
    {{- end }}
    {{- if $MAIN_OBJECT_BLOCK.autoscaling.hpa.targetCPU }}
    - type: Resource
      resource:
        name: cpu
        {{- if semverCompare "<1.23-0" (include "common.capabilities.kubeVersion" $context) }}
        targetAverageUtilization: {{ $MAIN_OBJECT_BLOCK.autoscaling.hpa.targetCPU }}
        {{- else }}
        target:
          type: Utilization
          averageUtilization: {{ $context.Values.worker.autoscaling.hpa.targetCPU }}
        {{- end }}
    {{- end }}
{{- end }}
{{- end -}}