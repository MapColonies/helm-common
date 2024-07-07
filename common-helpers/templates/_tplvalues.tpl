{{/*
Copyright VMware, Inc.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/* vim: set filetype=mustache: */}}
{{/*
Renders a value that contains template perhaps with scope if the scope is present.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ ) }}
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $ "scope" $app ) }}
*/}}
{{- define "common.tplvalues.render" -}}
{{- $value := typeIs "string" .value | ternary .value (.value | toYaml) }}
{{- if contains "{{" (toJson .value) }}
  {{- if .scope }}
      {{- tpl (cat "{{- with $.RelativeScope -}}" $value "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- else }}
    {{- tpl $value .context }}
  {{- end }}
{{- else }}
    {{- $value }}
{{- end }}
{{- end -}}

{{/*
Merge a list of values that contains template after rendering them.
Merge precedence is consistent with http://masterminds.github.io/sprig/dicts.html#merge-mustmerge
Usage:
{{ include "common.tplvalues.merge" ( dict "values" (list .Values.path.to.the.Value1 .Values.path.to.the.Value2) "context" $ ) }}
*/}}
{{- define "common.tplvalues.merge" -}}
{{- $dst := dict -}}
{{- range .values -}}
{{- $dst = include "common.tplvalues.render" (dict "value" . "context" $.context "scope" $.scope) | fromYaml | merge $dst -}}
{{- end -}}
{{ $dst | toYaml }}
{{- end -}}

{{/*
Get global property value according to MapColonies(MC) override principles
  global:
    logLevel: warning                 # MC common global value
    currentSubChart: serving          # One of serving/ingestion/etc.
    overrideGlobal:
      logLevel: info                  # Overridden global value
    serving:                          # Umbrella name
      overrideGlobal:
        logLevel: info                # Override for whole umrella global value
      nginx-s3-gateway:               # Chart name
        overrideGlobal:
          logLevel: debug             # Override chart global value
    ingestion:
      overrideGlobal:
        logLevel: info
Priority of global value:
  1. global.serving.nginx-s3-gateway.overrideGlobal.logLevel
  2. global.serving.overrideGlobal.logLevel
  3. global.overrideGlobal.logLevel
  4. global.logLevel
Usage:
{{ include "common.tplvalues.getGlobalValue" ( dict "propName" "logLevel" "context" . ) }}
*/}}
{{- define "common.tplvalues.getGlobalValue" -}}
{{- $context := .context }}
{{- $propName := .propName }}
{{- $CURRENT_SUB_CHART := $context.Values.global.currentSubChart -}}
{{- $CHART_GLOBAL_OVERRIDE := dig $CURRENT_SUB_CHART $context.Chart.Name "overrideGlobal" $propName "" $context.Values.global }}
{{- $UMBRELLA_GLOBAL_OVERRIDE := dig $CURRENT_SUB_CHART "overrideGlobal" $propName "" $context.Values.global }}
{{- $GLOBAL_OVERRIDE := dig "overrideGlobal" $propName "" $context.Values.global }}
{{- $GLOBAL := dig $propName "" $context.Values.global }}

{{- $GLOBAL_RESOLVED := default $GLOBAL (default $GLOBAL_OVERRIDE (default $UMBRELLA_GLOBAL_OVERRIDE $CHART_GLOBAL_OVERRIDE) ) -}}
{{- printf "%s" $GLOBAL_RESOLVED -}}
{{- end -}}

{{/*
Get global object according to MapColonies(MC) override principles (see above)
*/}}
{{- define "common.tplvalues.getGlobalObject" -}}
{{- $objName := .objName }}
{{- $context := .context }}
{{- $CURRENT_SUB_CHART := $context.Values.global.currentSubChart -}}
{{- $CURRENT_CHART := $context.Chart.Name -}}
{{- $CHART_GLOBAL_OVERRIDE := include "common.tplvalues.getObject" (dict "path" (printf "%s.%s.%s.%s" $CURRENT_SUB_CHART $CURRENT_CHART "overrideGlobal" $objName) "context" $context.Values.global) -}}
{{- $UMBRELLA_GLOBAL_OVERRIDE := include "common.tplvalues.getObject" (dict "path" (printf "%s.%s.%s" $CURRENT_SUB_CHART "overrideGlobal" $objName) "context" $context.Values.global) -}}
{{- $GLOBAL_OVERRIDE := include "common.tplvalues.getObject" (dict "path" (printf "%s.%s" "overrideGlobal" $objName) "context" $context.Values.global) -}}
{{- $GLOBAL := include "common.tplvalues.getObject" (dict "path" (printf "%s." $objName) "context" $context.Values.global) -}}
{{- $GLOBAL_RESOLVED := "" -}}

{{- if fromYaml $CHART_GLOBAL_OVERRIDE }}
{{- $GLOBAL_RESOLVED = $CHART_GLOBAL_OVERRIDE }}
{{- else if fromYaml $UMBRELLA_GLOBAL_OVERRIDE }}
{{- $GLOBAL_RESOLVED = $UMBRELLA_GLOBAL_OVERRIDE }}
{{- else if fromYaml $GLOBAL_OVERRIDE }}
{{- $GLOBAL_RESOLVED = $GLOBAL_OVERRIDE }}
{{- else }}
{{- $GLOBAL_RESOLVED = $GLOBAL }}
{{- end }}
{{- $GLOBAL_RESOLVED }}
{{- end -}}

{{/*
Get object according by path(string)
Usage:
  {{ include "common.tplvalues.getObject" (dict "path" "global.serving" "context" .Values) }}
*/}}
{{- define "common.tplvalues.getObject" -}}
{{- $path := .path }}
{{- $context := .context }}
{{- $pathParts := split "." $path }}
{{- $value := $context }}
{{- if $context }}
{{- range $pathParts }}
  {{- if and $value . }}
  {{- $value = index $value . }}
  {{- end }}
{{- end }}
{{- end }}
{{- $value | toYaml }}
{{- end -}}