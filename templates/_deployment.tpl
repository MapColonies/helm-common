{{/*
USAGE:
{{ include "mc-chart.deployment" (dict "MAIN_OBJECT_BLOCK" $MAIN_OBJECT_BLOCK "COMPONENT_NAME" $COMPONENT_NAME "context" .) }}
*/}}

{{- define "mc-chart.deployment" -}}
{{- $context := .context -}}
{{- $COMPONENT_NAME := .COMPONENT_NAME -}}
{{- $MAIN_OBJECT_BLOCK := get $context.Values .MAIN_OBJECT_BLOCK -}}
apiVersion: {{ include "common.capabilities.deployment.apiVersion" $context }}
kind: Deployment
metadata:
  name: {{ template "common.names.fullname" $context }}
  namespace: {{ include "common.names.namespace" $context | quote }}
  labels: {{- include "common.labels.standard" ( dict "customLabels" $context.Values.commonLabels "context" $context ) | nindent 4 }}
    app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    {{- include "mc.labels.standard" ( dict "context" $context ) | nindent 4 }}
  {{- if or $MAIN_OBJECT_BLOCK.deploymentAnnotations $context.Values.commonAnnotations }}
  {{- $annotations := include "common.tplvalues.merge" (dict "values" (list $MAIN_OBJECT_BLOCK.deploymentAnnotations $context.Values.commonAnnotations) "context" $context) }}
  annotations: {{- include "common.tplvalues.render" ( dict "value" $annotations "context" $context ) | nindent 4 }}
  {{- end }}
spec:
  {{- if not $MAIN_OBJECT_BLOCK.autoscaling.enabled }}
  replicas: {{ $MAIN_OBJECT_BLOCK.replicaCount }}
  {{- end }}
  revisionHistoryLimit: {{ default 5 $MAIN_OBJECT_BLOCK.revisionHistoryLimit }}
  {{- if $MAIN_OBJECT_BLOCK.updateStrategy }}
  strategy: {{- toYaml $MAIN_OBJECT_BLOCK.updateStrategy | nindent 4 }}
  {{- end }}
  {{- $podLabels := include "common.tplvalues.merge" (dict "values" (list $MAIN_OBJECT_BLOCK.podLabels $context.Values.commonLabels) "context" $context) }}
  selector:
    matchLabels: {{- include "common.labels.matchLabels" ( dict "customLabels" $podLabels "context" $context ) | nindent 6 }}
      app.kubernetes.io/component: {{ $COMPONENT_NAME }}
  template:
    metadata:
      {{- if $MAIN_OBJECT_BLOCK.podAnnotations.enabled }}
      annotations: 
        {{- if $MAIN_OBJECT_BLOCK.podAnnotations.resetOnConfigChange }}
        checksum/configmap: {{ include (print $context.Template.BasePath "/configmap.yaml") $context | sha256sum }}
        {{- end }}
        {{- if $MAIN_OBJECT_BLOCK.prometheus.scrape }}
        prometheus.io/scrape: {{ $MAIN_OBJECT_BLOCK.prometheus.scrape | quote }}
        prometheus.io/port: {{ $MAIN_OBJECT_BLOCK.prometheus.port | quote }}
        prometheus.io/path: {{ $MAIN_OBJECT_BLOCK.prometheus.path | quote }}
        prometheus.io/scheme: {{ $MAIN_OBJECT_BLOCK.prometheus.scheme | quote }}
        {{- range $idx, $obj := $MAIN_OBJECT_BLOCK.prometheus.params }}
        {{- range $key, $val := $obj }}
        prometheus.io/param_{{ $key }}: {{ $val | quote }}
        {{- end }}
        {{- end }}
        {{- end }}
        {{- if $MAIN_OBJECT_BLOCK.podAnnotations.annotations }}
        {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.podAnnotations.annotations "context" $context) | nindent 8 }}
        {{- end }}
      {{- end }}
      labels: {{- include "common.labels.matchLabels" ( dict "customLabels" $podLabels "context" $context ) | nindent 8 }}
        app.kubernetes.io/component: {{ $COMPONENT_NAME }}
    spec:
      {{- include "tplHelpers.imagePullSecrets" ( dict "MAIN_OBJECT_BLOCK" $MAIN_OBJECT_BLOCK "context" $context ) | nindent 6 }}
      serviceAccountName: {{ template "tplHelpers.serviceAccountName" $context }}
      automountServiceAccountToken: true
      {{- if $MAIN_OBJECT_BLOCK.hostAliases }}
      hostAliases: {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.hostAliases "context" $context) | nindent 8 }}
      {{- end }}
      {{- if $MAIN_OBJECT_BLOCK.affinity }}
      affinity: {{- include "common.tplvalues.render" ( dict "value" $MAIN_OBJECT_BLOCK.affinity "context" $context) | nindent 8 }}
      {{- else }}
      affinity:
        {{- if or (eq $MAIN_OBJECT_BLOCK.podAffinityPreset "soft") (eq $MAIN_OBJECT_BLOCK.podAffinityPreset "hard") }}
        podAffinity: {{- include "common.affinities.pods" (dict "type" $MAIN_OBJECT_BLOCK.podAffinityPreset "component" $COMPONENT_NAME "customLabels" $podLabels "context" $context) | nindent 10 }}
        {{- end }}
        {{- if or (eq $MAIN_OBJECT_BLOCK.podAntiAffinityPreset "soft") (eq $MAIN_OBJECT_BLOCK.podAntiAffinityPreset "hard") }}
        podAntiAffinity: {{- include "common.affinities.pods" (dict "type" $MAIN_OBJECT_BLOCK.podAntiAffinityPreset "component" $COMPONENT_NAME "customLabels" $podLabels "context" $context) | nindent 10 }}
        {{- end }}
        {{- if $MAIN_OBJECT_BLOCK.nodeAffinityPreset }}
        nodeAffinity: {{- include "common.affinities.nodes" (dict "type" $MAIN_OBJECT_BLOCK.nodeAffinityPreset.type "key" $MAIN_OBJECT_BLOCK.nodeAffinityPreset.key "values" $MAIN_OBJECT_BLOCK.nodeAffinityPreset.values) | nindent 10 }}
        {{- end }}
      {{- end }}
      {{- if $MAIN_OBJECT_BLOCK.nodeSelector }}
      nodeSelector: {{- include "common.tplvalues.render" ( dict "value" $MAIN_OBJECT_BLOCK.nodeSelector "context" $context) | nindent 8 }}
      {{- end }}
      {{- if $MAIN_OBJECT_BLOCK.tolerations }}
      tolerations: {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.tolerations "context" $context) | nindent 8 }}
      {{- end }}
      {{- if $MAIN_OBJECT_BLOCK.priorityClassName }}
      priorityClassName: {{ $MAIN_OBJECT_BLOCK.priorityClassName | quote }}
      {{- end }}
      {{- if $MAIN_OBJECT_BLOCK.schedulerName }}
      schedulerName: {{ $MAIN_OBJECT_BLOCK.schedulerName | quote }}
      {{- end }}
      {{- if $MAIN_OBJECT_BLOCK.topologySpreadConstraints }}
      topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.topologySpreadConstraints "context" $context) | nindent 8 }}
      {{- end }}
      {{- if $MAIN_OBJECT_BLOCK.podSecurityContext.enabled }}
      securityContext: {{- omit $MAIN_OBJECT_BLOCK.podSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if $MAIN_OBJECT_BLOCK.terminationGracePeriodSeconds }}
      terminationGracePeriodSeconds: {{ $MAIN_OBJECT_BLOCK.terminationGracePeriodSeconds }}
      {{- end }}
      initContainers:
        {{- if and $context.Values.volumePermissions.enabled $context.Values.persistence.enabled }}
        - name: volume-permissions
          image: {{ include "tplHelpers.volumePermissions.image" $context }}
          imagePullPolicy: {{ $context.Values.volumePermissions.image.pullPolicy | quote }}
          command:
          {{- if $context.Values.volumePermissions.containerSecurityContext.enabled }}
          securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" $context.Values.volumePermissions.containerSecurityContext "context" $context) | nindent 12 }}
          {{- end }}
          {{- if $context.Values.volumePermissions.resources }}
          resources: {{- toYaml $context.Values.volumePermissions.resources | nindent 12 }}
          {{- else if ne $context.Values.volumePermissions.resourcesPreset "none" }}
          resources: {{- include "common.resources.preset" (dict "type" $context.Values.volumePermissions.resourcesPreset) | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: data
              mountPath: {{ $context.Values.persistence.mountPath }}
              {{- if $context.Values.persistence.subPath }}
              subPath: {{ $context.Values.persistence.subPath }}
              {{- end }}
        {{- end }}
        {{- if $MAIN_OBJECT_BLOCK.initContainers }}
          {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.initContainers "context" $context) | nindent 8 }}
        {{- end }}
      containers:
        - name: {{ template "common.names.name" $context }}
          image: {{ include "tplHelpers.image" (dict "MAIN_OBJECT_BLOCK" $MAIN_OBJECT_BLOCK "context" $context) }}
          imagePullPolicy: {{ $MAIN_OBJECT_BLOCK.image.pullPolicy }}
          {{- if $MAIN_OBJECT_BLOCK.containerSecurityContext.enabled }}
          securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" $MAIN_OBJECT_BLOCK.containerSecurityContext "context" $context) | nindent 12 }}
          {{- end }}
          {{- if $context.Values.diagnosticMode.enabled }}
          command: {{- include "common.tplvalues.render" (dict "value" $context.Values.diagnosticMode.command "context" $context) | nindent 12 }}
          {{- else if $MAIN_OBJECT_BLOCK.command }}
          command: {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.command "context" $context) | nindent 12 }}
          {{- end }}
          {{- if $context.Values.diagnosticMode.enabled }}
          args: {{- include "common.tplvalues.render" (dict "value" $context.Values.diagnosticMode.args "context" $context) | nindent 12 }}
          {{- else if $MAIN_OBJECT_BLOCK.args }}
          args: {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.args "context" $context) | nindent 12 }}
          {{- end }}
          env:
            - name: MC_DEBUG
              value: {{ ternary "true" "false" (or $MAIN_OBJECT_BLOCK.image.debug $context.Values.diagnosticMode.enabled) | quote }}
            {{- if $MAIN_OBJECT_BLOCK.extraEnvVars }}
            {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.extraEnvVars "context" $context) | nindent 12 }}
            {{- end }}
          envFrom:
            {{- if $MAIN_OBJECT_BLOCK.extraEnvVarsCM }}
            - configMapRef:
                name: {{ include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.extraEnvVarsCM "context" $context) }}
            {{- end }}
            {{- if $MAIN_OBJECT_BLOCK.extraEnvVarsSecret }}
            - secretRef:
                name: {{ include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.extraEnvVarsSecret "context" $context) }}
            {{- end }}
          {{- if $MAIN_OBJECT_BLOCK.resources }}
          resources: {{- toYaml $MAIN_OBJECT_BLOCK.resources | nindent 12 }}
          {{- else if ne $MAIN_OBJECT_BLOCK.resourcesPreset "none" }}
          resources: {{- include "common.resources.preset" (dict "type" $MAIN_OBJECT_BLOCK.resourcesPreset) | nindent 12 }}
          {{- end }}
          ports:
            - name: http
              containerPort: {{ $MAIN_OBJECT_BLOCK.containerPorts.http }}
            - name: https
              containerPort: {{ $MAIN_OBJECT_BLOCK.containerPorts.https }}
          {{- if not $context.Values.diagnosticMode.enabled }}
          {{- if $MAIN_OBJECT_BLOCK.customLivenessProbe }}
          livenessProbe: {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.customLivenessProbe "context" $context) | nindent 12 }}
          {{- else if $MAIN_OBJECT_BLOCK.livenessProbe.enabled }}
          livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit $MAIN_OBJECT_BLOCK.livenessProbe "enabled") "context" $context) | nindent 12 }}
            {{- include "tplHelpers.probe.httpGet" (dict "PROBE_PATH" "liveness") | nindent 12 }}
          {{- end }}
          {{- if $MAIN_OBJECT_BLOCK.customReadinessProbe }}
          readinessProbe: {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.customReadinessProbe "context" $context) | nindent 12 }}
          {{- else if $MAIN_OBJECT_BLOCK.readinessProbe.enabled }}
          readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit $MAIN_OBJECT_BLOCK.readinessProbe "enabled") "context" $context) | nindent 12 }}
            {{- include "tplHelpers.probe.httpGet" (dict "PROBE_PATH" "liveness") | nindent 12 }}
          {{- end }}
          {{- if $MAIN_OBJECT_BLOCK.customStartupProbe }}
          startupProbe: {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.customStartupProbe "context" $context) | nindent 12 }}
          {{- else if $MAIN_OBJECT_BLOCK.startupProbe.enabled }}
          startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit $MAIN_OBJECT_BLOCK.startupProbe "enabled") "context" $context) | nindent 12 }}
            {{- include "tplHelpers.probe.httpGet" (dict "PROBE_PATH" "liveness") | nindent 12 }}
          {{- end }}
          {{- end }}
          {{- if $MAIN_OBJECT_BLOCK.lifecycleHooks }}
          lifecycle: {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.lifecycleHooks "context" $context) | nindent 12 }}
          {{- end }}
          volumeMounts:
            {{- if $context.Values.persistence.enabled }}
            - name: data
              mountPath: {{ $context.Values.persistence.mountPath }}
              {{- if $context.Values.persistence.subPath }}
              subPath: {{ $context.Values.persistence.subPath }}
              {{- end }}
            {{- end }}
            - name: empty-dir
              mountPath: /tmp
              subPath: tmp-dir
          {{- if $MAIN_OBJECT_BLOCK.extraVolumeMounts }}
          {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.extraVolumeMounts "context" $context) | nindent 12 }}
          {{- end }}
        {{- if $MAIN_OBJECT_BLOCK.sidecars }}
        {{- include "common.tplvalues.render" ( dict "value" $MAIN_OBJECT_BLOCK.sidecars "context" $context) | nindent 8 }}
        {{- end }}
      volumes:
        - name: empty-dir
          emptyDir: {}
        {{- if $context.Values.persistence.enabled }}
        - name: data
          persistentVolumeClaim:
            claimName: {{ default (include "common.names.fullname" $context) $context.Values.persistence.existingClaim }}
        {{- end }}
        {{- if $MAIN_OBJECT_BLOCK.extraVolumes }}
        {{- include "common.tplvalues.render" (dict "value" $MAIN_OBJECT_BLOCK.extraVolumes "context" $context) | nindent 8 }}
        {{- end }}  
{{- end }}