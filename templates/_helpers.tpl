{{/* vim: set filetype=mustache: */}}
{{/* Expand the name of the chart. This is suffixed with -alertmanager, which means subtract 13 from longest 63 available */}}
{{- define "unitest-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "unitest-stack.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Fullname suffixed with operator */}}
{{- define "unitest-stack.operator.fullname" -}}
{{- printf "%s-operator" (include "unitest-stack.fullname" .) -}}
{{- end }}

{{/* Prometheus custom resource instance name */}}
{{- define "unitest-stack.prometheus.crname" -}}
{{- if .Values.cleanPrometheusOperatorObjectNames }}
{{- include "unitest-stack.fullname" . }}
{{- else }}
{{- print (include "unitest-stack.fullname" .) "-prometheus" }}
{{- end }}
{{- end }}

{{/* Prometheus apiVersion for networkpolicy */}}
{{- define "unitest-stack.prometheus.networkPolicy.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end }}

{{/* Alertmanager custom resource instance name */}}
{{- define "unitest-stack.alertmanager.crname" -}}
{{- if .Values.cleanPrometheusOperatorObjectNames }}
{{- include "unitest-stack.fullname" . }}
{{- else }}
{{- print (include "unitest-stack.fullname" .) "-alertmanager" -}}
{{- end }}
{{- end }}

{{/* Fullname suffixed with thanos-ruler */}}
{{- define "unitest-stack.thanosRuler.fullname" -}}
{{- printf "%s-thanos-ruler" (include "unitest-stack.fullname" .) -}}
{{- end }}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "unitest-stack.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "unitest-stack.labels" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ replace "+" "_" .Chart.Version }}"
app.kubernetes.io/part-of: {{ template "unitest-stack.name" . }}
chart: {{ template "unitest-stack.chartref" . }}
release: {{ $.Release.Name | quote }}
heritage: {{ $.Release.Service | quote }}
{{- if .Values.commonLabels}}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/* Create the name of unitest-stack service account to use */}}
{{- define "unitest-stack.operator.serviceAccountName" -}}
{{- if .Values.prometheusOperator.serviceAccount.create -}}
    {{ default (include "unitest-stack.operator.fullname" .) .Values.prometheusOperator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.prometheusOperator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of prometheus service account to use */}}
{{- define "unitest-stack.prometheus.serviceAccountName" -}}
{{- if .Values.prometheus.serviceAccount.create -}}
    {{ default (print (include "unitest-stack.fullname" .) "-prometheus") .Values.prometheus.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.prometheus.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of alertmanager service account to use */}}
{{- define "unitest-stack.alertmanager.serviceAccountName" -}}
{{- if .Values.alertmanager.serviceAccount.create -}}
    {{ default (print (include "unitest-stack.fullname" .) "-alertmanager") .Values.alertmanager.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.alertmanager.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Create the name of thanosRuler service account to use */}}
{{- define "unitest-stack.thanosRuler.serviceAccountName" -}}
{{- if .Values.thanosRuler.serviceAccount.create -}}
    {{ default (include "unitest-stack.thanosRuler.fullname" .) .Values.thanosRuler.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.thanosRuler.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "unitest-stack.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Use the grafana namespace override for multi-namespace deployments in combined charts
*/}}
{{- define "unitest-stack-grafana.namespace" -}}
  {{- if .Values.grafana.namespaceOverride -}}
    {{- .Values.grafana.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Use the kube-state-metrics namespace override for multi-namespace deployments in combined charts
*/}}
{{- define "unitest-stack-kube-state-metrics.namespace" -}}
  {{- if index .Values "kube-state-metrics" "namespaceOverride" -}}
    {{- index .Values "kube-state-metrics" "namespaceOverride" -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
Use the prometheus-node-exporter namespace override for multi-namespace deployments in combined charts
*/}}
{{- define "unitest-stack-prometheus-node-exporter.namespace" -}}
  {{- if index .Values "prometheus-node-exporter" "namespaceOverride" -}}
    {{- index .Values "prometheus-node-exporter" "namespaceOverride" -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/* Allow KubeVersion to be overridden. */}}
{{- define "unitest-stack.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride -}}
{{- end -}}

{{/* Get Ingress API Version */}}
{{- define "unitest-stack.ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19-0" (include "unitest-stack.kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/* Check Ingress stability */}}
{{- define "unitest-stack.ingress.isStable" -}}
  {{- eq (include "unitest-stack.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/* Check Ingress supports pathType */}}
{{/* pathType was added to networking.k8s.io/v1beta1 in Kubernetes 1.18 */}}
{{- define "unitest-stack.ingress.supportsPathType" -}}
  {{- or (eq (include "unitest-stack.ingress.isStable" .) "true") (and (eq (include "unitest-stack.ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18-0" (include "unitest-stack.kubeVersion" .))) -}}
{{- end -}}

{{/* Get Policy API Version */}}
{{- define "unitest-stack.pdb.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "policy/v1") (semverCompare ">= 1.21-0" (include "unitest-stack.kubeVersion" .)) -}}
      {{- print "policy/v1" -}}
  {{- else -}}
    {{- print "policy/v1beta1" -}}
  {{- end -}}
  {{- end -}}

{{/* Get value based on current Kubernetes version */}}
{{- define "unitest-stack.kubeVersionDefaultValue" -}}
  {{- $values := index . 0 -}}
  {{- $kubeVersion := index . 1 -}}
  {{- $old := index . 2 -}}
  {{- $new := index . 3 -}}
  {{- $default := index . 4 -}}
  {{- if kindIs "invalid" $default -}}
    {{- if semverCompare $kubeVersion (include "unitest-stack.kubeVersion" $values) -}}
      {{- print $new -}}
    {{- else -}}
      {{- print $old -}}
    {{- end -}}
  {{- else -}}
    {{- print $default }}
  {{- end -}}
{{- end -}}

{{/* Get value for kube-controller-manager depending on insecure scraping availability */}}
{{- define "unitest-stack.kubeControllerManager.insecureScrape" -}}
  {{- $values := index . 0 -}}
  {{- $insecure := index . 1 -}}
  {{- $secure := index . 2 -}}
  {{- $userValue := index . 3 -}}
  {{- include "unitest-stack.kubeVersionDefaultValue" (list $values ">= 1.22-0" $insecure $secure $userValue) -}}
{{- end -}}

{{/* Get value for kube-scheduler depending on insecure scraping availability */}}
{{- define "unitest-stack.kubeScheduler.insecureScrape" -}}
  {{- $values := index . 0 -}}
  {{- $insecure := index . 1 -}}
  {{- $secure := index . 2 -}}
  {{- $userValue := index . 3 -}}
  {{- include "unitest-stack.kubeVersionDefaultValue" (list $values ">= 1.23-0" $insecure $secure $userValue) -}}
{{- end -}}

{{/*
To help compatibility with other charts which use global.imagePullSecrets.
Allow either an array of {name: pullSecret} maps (k8s-style), or an array of strings (more common helm-style).
global:
  imagePullSecrets:
  - name: pullSecret1
  - name: pullSecret2

or

global:
  imagePullSecrets:
  - pullSecret1
  - pullSecret2
*/}}
{{- define "unitest-stack.imagePullSecrets" -}}
{{- range .Values.global.imagePullSecrets }}
  {{- if eq (typeOf .) "map[string]interface {}" }}
- {{ toYaml . | trim }}
  {{- else }}
- name: {{ . }}
  {{- end }}
{{- end }}
{{- end -}}
