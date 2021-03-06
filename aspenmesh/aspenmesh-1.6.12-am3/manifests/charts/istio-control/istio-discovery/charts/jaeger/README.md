# Jaeger

[Jaeger](https://www.jaegertracing.io/) is a distributed tracing system.

## Introduction

This chart adds all components required to run Jaeger as described in the [jaeger-kubernetes](https://github.com/jaegertracing/jaeger-kubernetes) GitHub page for a production-like deployment. The chart default will deploy a new Cassandra cluster (using the [cassandra chart](https://github.com/kubernetes/charts/tree/master/incubator/cassandra)), but also supports using an existing Cassandra cluster, deploying a new ElasticSearch cluster (using the [elasticsearch chart](https://github.com/elastic/helm-charts/tree/master/elasticsearch)), or connecting to an existing ElasticSearch cluster. Once the storage backend is available, the chart will deploy jaeger-agent as a DaemonSet and deploy the jaeger-collector and jaeger-query components as Deployments.

## Installing the Chart

Add the Jaeger Tracing Helm repository:

```bash
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
```

To install the chart with the release name `jaeger`, run the following command:

```bash
helm install jaeger jaegertracing/jaeger
```

By default, the chart deploys the following:

 - Jaeger Agent DaemonSet
 - Jaeger Collector Deployment
 - Jaeger Query (UI) Deployment
 - Cassandra StatefulSet

![Jaeger with Default components](images/jaeger-default.png)

IMPORTANT NOTE: For testing purposes, the footprint for Cassandra can be reduced significantly in the event resources become constrained (such as running on your local laptop or in a Vagrant environment). You can override the resources required run running this command:

```bash
helm install jaeger jaegertracing/jaeger \
  --set cassandra.config.max_heap_size=1024M \
  --set cassandra.config.heap_new_size=256M \
  --set cassandra.resources.requests.memory=2048Mi \
  --set cassandra.resources.requests.cpu=0.4 \
  --set cassandra.resources.limits.memory=2048Mi \
  --set cassandra.resources.limits.cpu=0.4
```

## Installing the Chart using an Existing Cassandra Cluster

If you already have an existing running Cassandra cluster, you can configure the chart as follows to use it as your backing store (make sure you replace `<HOST>`, `<PORT>`, etc with your values):

```bash
helm install jaeger jaegertracing/jaeger \
  --set provisionDataStore.cassandra=false \
  --set storage.cassandra.host=<HOST> \
  --set storage.cassandra.port=<PORT> \
  --set storage.cassandra.user=<USER> \
  --set storage.cassandra.password=<PASSWORD>
```

## Installing the Chart using an Existing Cassandra Cluster with TLS

If you already have an existing running Cassandra cluster with TLS, you can configure the chart as follows to use it as your backing store:

Content of the `values.yaml` file:

```YAML
storage:
  type: cassandra
  cassandra:
    host: <HOST>
    port: <PORT>
    user: <USER>
    password: <PASSWORD>
    tls:
      enabled: true
      secretName: cassandra-tls-secret

provisionDataStore:
  cassandra: false
```

Content of the `jaeger-tls-cassandra-secret.yaml` file:

```YAML
apiVersion: v1
kind: Secret
metadata:
  name: cassandra-tls-secret
data:
  commonName: <SERVER NAME>
  ca-cert.pem: |
    -----BEGIN CERTIFICATE-----
    <CERT>
    -----END CERTIFICATE-----
  client-cert.pem: |
    -----BEGIN CERTIFICATE-----
    <CERT>
    -----END CERTIFICATE-----
  client-key.pem: |
    -----BEGIN RSA PRIVATE KEY-----
    -----END RSA PRIVATE KEY-----
  cqlshrc: |
    [ssl]
    certfile = ~/.cassandra/ca-cert.pem
    userkey = ~/.cassandra/client-key.pem
    usercert = ~/.cassandra/client-cert.pem

```

```bash
kubectl apply -f jaeger-tls-cassandra-secret.yaml
helm install jaeger jaegertracing/jaeger --values values.yaml
```

## Installing the Chart using a New ElasticSearch Cluster

To install the chart with the release name `jaeger` using a new ElasticSearch cluster instead of Cassandra (default), run the following command:

```bash
helm install jaeger jaegertracing/jaeger \
  --set provisionDataStore.cassandra=false \
  --set provisionDataStore.elasticsearch=true \
  --set storage.type=elasticsearch
```

## Installing the Chart using an Existing Elasticsearch Cluster

A release can be configured as follows to use an existing ElasticSearch cluster as it as the storage backend:

```bash
helm install jaeger jaegertracing/jaeger \
  --set provisionDataStore.cassandra=false \
  --set storage.type=elasticsearch \
  --set storage.elasticsearch.host=<HOST> \
  --set storage.elasticsearch.port=<PORT> \
  --set storage.elasticsearch.user=<USER> \
  --set storage.elasticsearch.password=<password>
```

## Installing the Chart using an Existing ElasticSearch Cluster with TLS

If you already have an existing running ElasticSearch cluster with TLS, you can configure the chart as follows to use it as your backing store:

Content of the `jaeger-values.yaml` file:

```YAML
storage:
  type: elasticsearch
  elasticsearch:
    host: <HOST>
    port: <PORT>
    scheme: https
    user: <USER>
    password: <PASSWORD>
provisionDataStore:
  cassandra: false
  elasticsearch: false
query:
  cmdlineParams:
    es.tls.ca: "/tls/es.pem"
  extraConfigmapMounts:
    - name: jaeger-tls
      mountPath: /tls
      subPath: ""
      configMap: jaeger-tls
      readOnly: true
collector:
  cmdlineParams:
    es.tls.ca: "/tls/es.pem"
  extraConfigmapMounts:
    - name: jaeger-tls
      mountPath: /tls
      subPath: ""
      configMap: jaeger-tls
      readOnly: true
```

Content of the `jaeger-tls-cfgmap.yaml` file:

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: jaeger-tls
data:
  es.pem: |
    -----BEGIN CERTIFICATE-----
    <CERT>
    -----END CERTIFICATE-----
```

```bash
kubectl apply -f jaeger-tls-cfgmap.yaml
helm install jaeger jaegertracing/jaeger --values jaeger-values.yaml
```

## Installing the Chart with Ingester enabled

The architecture illustrated below can be achieved by enabling the ingester component. When enabled, Cassandra or Elasticsearch (depending on the configured values) now becomes the ingester's storage backend, whereas Kafka becomes the storage backend of the collector service.

![Jaeger with Ingester](images/jaeger-with-ingester.png)


## Installing the Chart with Ingester enabled using a New Kafka Cluster

To provision a new Kafka cluster along with jaeger-ingester:

```bash
helm install jaeger jaegertracing/jaeger \
  --set provisionDataStore.kafka=true \
  --set ingester.enabled=true
```

## Installing the Chart with Ingester using an existing Kafka Cluster

You can use an exisiting Kafka cluster with jaeger too

```bash
helm install jaeger jaegertracing/jaeger \
  --set ingester.enabled=true \
  --set storage.kafka.brokers={<BROKER1:PORT>,<BROKER2:PORT>} \
  --set storage.kafka.topic=<TOPIC>
```

## Configuration

The following table lists the configurable parameters of the Jaeger chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `<component>.nodeSelector` | Node selector | {} |
| `<component>.tolerations` | Node tolerations | [] |
| `<component.affinity` | Affinity | {} |
| `<component>.podSecurityContext` | Pod security context | {} |
| `<component>.securityContext` | Container security context | {} |
| `agent.annotations` | Annotations for Agent | `nil` |
| `agent.cmdlineParams` |Additional command line parameters| `nil` |
| `agent.dnsPolicy` | Configure DNS policy for agents | `ClusterFirst` |
| `agent.service.annotations` | Annotations for Agent SVC | `nil` |
| `agent.service.binaryPort` | jaeger.thrift over binary thrift | `6832` |
| `agent.service.compactPort` | jaeger.thrift over compact thrift| `6831` |
| `agent.image` | Image for Jaeger Agent | `jaegertracing/jaeger-agent` |
| `agent.podAnnotations` | Annotations for Agent pod | `nil` |
| `agent.pullPolicy` | Agent image pullPolicy | `IfNotPresent` |
| `agent.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]` |
| `agent.service.annotations` | Annotations for Agent SVC | `nil` |
| `agent.service.binaryPort` | jaeger.thrift over binary thrift | `6832` |
| `agent.service.compactPort` | jaeger.thrift over compact thrift | `6831` |
| `agent.service.zipkinThriftPort` | zipkin.thrift over compact thrift | `5775` |
| `agent.extraConfigmapMounts` | Additional agent configMap mounts | `[]` |
| `agent.extraSecretMounts` | Additional agent secret mounts | `[]` |
| `agent.useHostNetwork` | Enable hostNetwork for agents | `false` |
| `collector.autoscaling.enabled` | Enable horizontal pod autoscaling | `false` |
| `collector.autoscaling.minReplicas` | Minimum replicas |  2 |
| `collector.autoscaling.maxReplicas` | Maximum replicas |  10 |
| `collector.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization |  80 |
| `collector.autoscaling.targetMemoryUtilizationPercentage` | Target memory utilization | `nil` |
| `collector.cmdlineParams` | Additional command line parameters | `nil` |
| `collector.podAnnotations` | Annotations for Collector pod | `nil` |
| `collector.service.httpPort` | Client port for HTTP thrift | `14268` |
| `collector.service.annotations` | Annotations for Collector SVC | `nil` |
| `collector.image` | Image for jaeger collector | `jaegertracing/jaeger-collector` |
| `collector.pullPolicy` | Collector image pullPolicy | `IfNotPresent` |
| `collector.service.annotations` | Annotations for Collector SVC | `nil` |
| `collector.service.httpPort` | Client port for HTTP thrift | `14268` |
| `collector.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]` |
| `collector.service.tchannelPort` | Jaeger Agent port for thrift| `14267` |
| `collector.service.type` | Service type | `ClusterIP` |
| `collector.service.zipkinPort` | Zipkin port for JSON/thrift HTTP | `nil` |
| `collector.extraConfigmapMounts` | Additional collector configMap mounts | `[]` |
| `collector.extraSecretMounts` | Additional collector secret mounts | `[]` |
| `collector.samplingConfig` | [Sampling strategies json file](https://www.jaegertracing.io/docs/latest/sampling/#collector-sampling-configuration) | `nil` |
| `ingester.enabled` | Enable ingester component, collectors will write to Kafka | `false` |
| `ingester.autoscaling.enabled` | Enable horizontal pod autoscaling | `false` |
| `ingester.autoscaling.minReplicas` | Minimum replicas |  2 |
| `ingester.autoscaling.maxReplicas` | Maximum replicas |  10 |
| `ingester.autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization |  80 |
| `ingester.autoscaling.targetMemoryUtilizationPercentage` | Target memory utilization | `nil` |
| `ingester.cmdlineParams` | Additional command line parameters | `nil` |
| `ingester.podAnnotations` | Annotations for Ingester pod | `nil` |
| `ingester.service.annotations` | Annotations for Ingester SVC | `nil` |
| `ingester.image` | Image for jaeger Ingester | `jaegertracing/jaeger-ingester` |
| `ingester.pullPolicy` | Ingester image pullPolicy | `IfNotPresent` |
| `ingester.service.annotations` | Annotations for Ingester SVC | `nil` |
| `ingester.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]` |
| `ingester.service.type` | Service type | `ClusterIP` |
| `ingester.extraConfigmapMounts` | Additional Ingester configMap mounts | `[]` |
| `ingester.extraSecretMounts` | Additional Ingester secret mounts | `[]` |
| `fullnameOverride` | Override full name | `nil` |
| `hotrod.enabled` | Enables the Hotrod demo app | `false` |
| `hotrod.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]` |
| `nameOverride` | Override name| `nil` |
| `provisionDataStore.cassandra` | Provision Cassandra Data Store| `true` |
| `provisionDataStore.elasticsearch` | Provision Elasticsearch Data Store | `false` |
| `provisionDataStore.kafka` | Provision Kafka Data Store | `false` |
| `query.agentSidecar.enabled` | Enable agent sidecare for query deployment | `true` |
| `query.service.annotations` | Annotations for Query SVC | `nil` |
| `query.cmdlineParams` | Additional command line parameters | `nil` |
| `query.image` | Image for Jaeger Query UI | `jaegertracing/jaeger-query` |
| `query.ingress.enabled` | Allow external traffic access | `false` |
| `query.ingress.annotations` | Configure annotations for Ingress | `{}` |
| `query.ingress.hosts` | Configure host for Ingress | `nil` |
| `query.ingress.tls` | Configure tls for Ingress | `nil` |
| `query.podAnnotations` | Annotations for Query pod | `nil` |
| `query.pullPolicy` | Query UI image pullPolicy | `IfNotPresent` |
| `query.service.loadBalancerSourceRanges` | list of IP CIDRs allowed access to load balancer (if supported) | `[]` |
| `query.service.port` | External accessible port | `80` |
| `query.service.type` | Service type | `ClusterIP` |
| `query.basePath` | Base path of Query UI, used for ingress as well (if it is enabled) | `/` |
| `query.extraConfigmapMounts` | Additional query configMap mounts | `[]` |
| `schema.annotations` | Annotations for the schema job| `nil` |
| `schema.extraConfigmapMounts` | Additional cassandra schema job configMap mounts | `[]  |
| `schema.image` | Image to setup cassandra schema | `jaegertracing/jaeger-cassandra-schema` |
| `schema.mode` | Schema mode (prod or test | `prod` |
| `schema.pullPolicy` | Schema image pullPolicy | `IfNotPresent` |
| `schema.activeDeadlineSeconds` | Deadline in seconds for cassandra schema creation job to complete | `120` |
| `schema.traceTtl` | Time to live for trace data in seconds | `nil` |
| `schema.keyspace` | Set explicit keyspace name | `nil` |
| `schema.dependenciesTtl` | Time to live for dependencies data in seconds | `nil` |
| `serviceAccounts.agent.create` | Create service account | `true` |
| `serviceAccounts.agent.name` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template | `` |
| `serviceAccounts.cassandraSchema.create` | Create service account | `true` |
| `serviceAccounts.cassandraSchema.name` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template | `` |
| `serviceAccounts.collector.create` | Create service account | `true` |
| `serviceAccounts.collector.name` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template | `` |
| `serviceAccounts.hotrod.create` | Create service account | `true` |
| `serviceAccounts.hotrod.name` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template | `` |
| `serviceAccounts.query.create` | Create service account | `true` |
| `serviceAccounts.query.name` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template | `` |
| `serviceAccounts.spark.create` | Create service account | `true` |
| `serviceAccounts.spark.name` | The name of the ServiceAccount to use. If not set and create is true, a name is generated using the fullname template | `` |
| `spark.enabled` | Enables the dependencies job| `false` |
| `spark.image` | Image for the dependencies job| `jaegertracing/spark-dependencies` |
| `spark.pullPolicy` | Image pull policy of the deps image | `Always` |
| `spark.schedule` | Schedule of the cron job | `"49 23 * * *"` |
| `spark.successfulJobsHistoryLimit` | Cron job successfulJobsHistoryLimit | `5` |
| `spark.failedJobsHistoryLimit` | Cron job failedJobsHistoryLimit | `5` |
| `spark.tag` | Tag of the dependencies job image | `latest` |
| `storage.cassandra.existingSecret` | Name of existing password secret object (for password authentication | `nil`
| `storage.cassandra.host` | Provisioned cassandra host | `cassandra` |
| `storage.cassandra.keyspace` | Schema name for cassandra | `jaeger_v1_test` |
| `storage.cassandra.password` | Provisioned cassandra password  (ignored if storage.cassandra.existingSecret set) | `password` |
| `storage.cassandra.port` | Provisioned cassandra port | `9042` |
| `storage.cassandra.tls.enabled` | Provisioned cassandra TLS connection enabled | `false` |
| `storage.cassandra.tls.secretName` | Provisioned cassandra TLS connection existing secret name (possible keys in secret: `ca-cert.pem`, `client-key.pem`, `client-cert.pem`, `cqlshrc`, `commonName`) | `` |
| `storage.cassandra.usePassword` | Use password | `true` |
| `storage.cassandra.user` | Provisioned cassandra username | `user` |
| `storage.elasticsearch.existingSecret` | Name of existing password secret object (for password authentication | `nil` |
| `storage.elasticsearch.host` | Provisioned elasticsearch host| `elasticsearch` |
| `storage.elasticsearch.password` | Provisioned elasticsearch password  (ignored if storage.elasticsearch.existingSecret set | `changeme` |
| `storage.elasticsearch.port` | Provisioned elasticsearch port| `9200` |
| `storage.elasticsearch.scheme` | Provisioned elasticsearch scheme | `http` |
| `storage.elasticsearch.usePassword` | Use password | `true` |
| `storage.elasticsearch.user` | Provisioned elasticsearch user| `elastic` |
| `storage.elasticsearch.nodesWanOnly` | Only access specified es host | `false` |
| `storage.kafka.brokers` | Broker List for Kafka with port | `kafka:9092` |
| `storage.kafka.topic` | Topic name for Kafka | `jaeger_v1_test` |
| `storage.type` | Storage type (ES or Cassandra)| `cassandra` |
| `tag` | Image tag/version | `1.16.0` |

For more information about some of the tunable parameters that Cassandra provides, please visit the helm chart for [cassandra](https://github.com/kubernetes/charts/tree/master/incubator/cassandra) and the official [website](http://cassandra.apache.org/) at apache.org.

For more information about some of the tunable parameters that Jaeger provides, please visit the official [Jaeger repo](https://github.com/uber/jaeger) at GitHub.com.

### Pending enhancements
- [ ] Sidecar deployment support
