# Unitest Helm Chart
* Installs [Prometheus](https://prometheus.io/)
* Installs [Grafana](http://grafana.org/)
* Installs [BlackBox exporter](https://github.com/prometheus/blackbox_exporter)
## Overview of Helm Chart

```console
.
├── charts
├── Chart.yaml
├── crds
│   ├── crd-podmonitors.yaml
│   ├── crd-probes.yaml
│   ├── crd-prometheuses.yaml
│   ├── crd-prometheusrules.yaml
│   └── crd-servicemonitors.yaml
├── templates
│   ├── grafana
│   ├── _helpers.tpl
│   ├── prometheus
│   └── prometheus-operator
└── values.yaml
```
Helm Chart consist of:
* [charts](./charts) - a directory containing any charts upon which this chart depends;
* [Chart.yaml](./Chart.yaml) - main YAML file containing information about the chart;
* [crds](./crds) - Custom Resource Definitions;
* [values.yaml](./values.yaml) - the default configuration values for this chart;
* [templates](./templates) - a directory of templates that, when combined with values, will generate valid Kubernetes manifest files:
  * [grafana](./templates/grafana) - a directory of Grafana templates;
  * [prometheus](./templates/prometheus) - a directory of Prometheus templates; 
  * [prometheus-operator](./templates/prometheus-operator) - a directory of Prometheus-operator templates.

## How to deploy Helm Chart

1. As Chart have dependent charts (`Grafana, Blackbox exporter`), firstly, you should install dependencies:
```console
$ helm dependency build
Getting updates for unmanaged Helm repositories...
...Successfully got an update from the "https://grafana.github.io/helm-charts" chart repository
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 2 charts
Downloading prometheus-blackbox-exporter from repo https://prometheus-community.github.io/helm-charts
Downloading grafana from repo https://grafana.github.io/helm-charts
Deleting outdated charts
```
**!NOTICE!** `This action needs to be performed only ONCE`

2. Deploying Helm Chart

To deploy Helm Chart to `unitest` namespace, use command:
```console
$ helm upgrade --install unitest-chart ./  --values ./values.yaml --namespace unitest --create-namespace
```
Where:
* `--install` - install if Chart does not exist;
* `unitest-chart ./` - name and path of Chart;
* `--values` - path to values file;
* `--namespace` - in which namespace Chart will be installed;
* `--create-namespace` - create namespace specified in `--namespace`.

3. Updating Helm Chart
If you want change or edit some in Helm Chart, will go to the `values.yaml` file, and change required values. After this, run command:
```console
$ helm upgrade --install unitest-chart ./  --values ./values.yaml --namespace unitest --create-namespace
```

## How to destroy Helm Chart
To destroy Helm Chart run this command:
```console
$ helm uninstall  unitest-chart ./  --namespace unitest
```
After this, delete `unitest` namespace:
```console
$ kubectl delete namespace unitest                                     
namespace "unitest" deleted
```

## Extra
### Grafana
To get access to Grafana use kubectl port-forwarding, that forward port of Grafana service to your localhost port:
```console
$ kubectl port-forward service/unitest-chart-grafana {your_local_port}:80  -n unitest
Forwarding from 127.0.0.1:{your_local_port} -> 3000
Forwarding from [::1]:{your_local_port} -> 3000
```
Open your browser and go to `localhost:{your_local_port}`.

To close this connection use `Ctrl+C`.
