# Linea Helm Chart

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

This Helm chart deploys the full **Linea stack**, including:

* **Besu**: a blockchain client rpc node receiving transactions and propagating them to the rest of the network
* **EthStats**: a web UI which displays network nodes status like latest block, number of peers, etc.
* **Maru**: an in-house developed consensus client, similar to Teku and others, which is proposing and signing blocks (since we're running Paris fork)
* **Sequencer**: an execution layer sequencer which is in charge of sequencing(ordering) transactions in a block

It provides a complete configuration surface with persistence, metrics, Gateway API support, autoscaling, and customizable security contexts.

## Design considerations

### Secrets
 
Secrets are stored within Kubernetes `Secrets` to remain agnostic of any particular solution.
Vault, External-Secrets Operator and other similar solutions can be added afterwards.

### Gateway API

[Gateway API](https://gateway-api.sigs.k8s.io/) was chosen over traditional `Ingress` resources because it provides:
- Better traffic routing capabilities with more granular control
- Enhanced security features through route-specific policies
- Native multi-cluster support for future scalability
- Standardized way to expose services across different Kubernetes providers

### Persistent Storage

Linea components are designing using `Statefulset` set. `Statefulset` creates `PersistantVolumeClaim` which use the AWS EBS CSI
`StorageClass` to provision in AWS a disk on-demand.

---

## 📦 Installation

```sh
helm repo add linea oci://public.ecr.aws/j0t0w2r4/linea
helm install my-linea linea/linea-stack
```

You can override any value using:

```sh
helm install my-linea linea/linea-stack -f values.example.yaml
```

---

## 🛠️ Configuration

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| besu.affinity | object | `{}` | Pod affinity settings. |
| besu.containerPorts | object | `{"engine":8550,"metrics":9547,"rpc":8545,"ws":8546}` | Container port mappings for the Besu client. |
| besu.containerPorts.engine | int | `8550` | Internal container port for the Engine API. |
| besu.containerPorts.metrics | int | `9547` | Internal container port for metrics (Prometheus). |
| besu.containerPorts.rpc | int | `8545` | Internal container port for JSON-RPC. |
| besu.containerPorts.ws | int | `8546` | Internal container port for WebSocket. |
| besu.httpRoute | object | `{"annotations":{},"enabled":false,"hostnames":[],"parentRefs":[{"name":"gateway","sectionName":"http"}],"rules":[{"matches":[{"path":{"type":"PathPrefix","value":"/headers"}}]}]}` | Kubernetes Gateway API HttpRoute configuration (if using the Gateway API). |
| besu.httpRoute.annotations | object | `{}` | Annotations for the HttpRoute resource. |
| besu.httpRoute.enabled | bool | `false` | Enable or disable HttpRoute creation. |
| besu.httpRoute.hostnames | list | `[]` | List of hostnames the route should match. |
| besu.httpRoute.parentRefs | list | `[{"name":"gateway","sectionName":"http"}]` | List of parent Gateways this route is attached to. |
| besu.httpRoute.rules | list | `[{"matches":[{"path":{"type":"PathPrefix","value":"/headers"}}]}]` | Routing rules. |
| besu.httpRoute.rules[0].matches[0].path.type | string | `"PathPrefix"` | Type of path matching (e.g., PathPrefix). |
| besu.httpRoute.rules[0].matches[0].path.value | string | `"/headers"` | The path value to match. |
| besu.image | object | `{"pullPolicy":"IfNotPresent","repository":"consensys/linea-besu-package","tag":"beta-v4.0-rc20-20251104100707-3294a02"}` | Docker image settings for the Besu client. |
| besu.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| besu.image.repository | string | `"consensys/linea-besu-package"` | Docker repository path for the Besu image. |
| besu.image.tag | string | `"beta-v4.0-rc20-20251104100707-3294a02"` | Specific Docker image tag (version) to use. |
| besu.imagePullSecrets | list | `[]` | List of secrets used for pulling images from private registries. |
| besu.livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/liveness","port":8545},"initialDelaySeconds":180,"periodSeconds":60,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration. |
| besu.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the probe to be considered failed. |
| besu.livenessProbe.httpGet | object | `{"path":"/liveness","port":8545}` | HTTP GET action for the probe. |
| besu.livenessProbe.httpGet.path | string | `"/liveness"` | Path to check. |
| besu.livenessProbe.httpGet.port | int | `8545` | Port to check. |
| besu.livenessProbe.initialDelaySeconds | int | `180` | Number of seconds after the container has started before liveness probes are initiated. |
| besu.livenessProbe.periodSeconds | int | `60` | How often to perform the probe (seconds). |
| besu.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed. |
| besu.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out. |
| besu.metrics | object | `{"enabled":false,"service":{"servicePort":9547,"type":"ClusterIP"},"serviceMonitor":{"enabled":false}}` | Metrics configuration. |
| besu.metrics.enabled | bool | `false` | Enable or disable Prometheus metrics endpoint. |
| besu.metrics.service | object | `{"servicePort":9547,"type":"ClusterIP"}` | Service definition for the metrics endpoint. |
| besu.metrics.service.servicePort | int | `9547` | Metrics service port. |
| besu.metrics.service.type | string | `"ClusterIP"` | Kubernetes Service type (e.g., ClusterIP, NodePort, LoadBalancer). |
| besu.metrics.serviceMonitor | object | `{"enabled":false}` | Prometheus ServiceMonitor configuration (requires prometheus-operator). |
| besu.metrics.serviceMonitor.enabled | bool | `false` | Enable or disable ServiceMonitor creation. |
| besu.name | string | `"besu"` | The component name, used for internal identification |
| besu.nodeSelector | object | `{}` | Node selection constraints. |
| besu.podAnnotations | object | `{}` | Annotations to add to the Pod metadata. |
| besu.podLabels | object | `{}` | Labels to add to the Pod metadata. |
| besu.podSecurityContext | object | `{}` | Security context applied to the Pod. |
| besu.readinessProbe | object | `{}` | Readiness probe configuration. |
| besu.resources | object | `{}` | Resource limits and requests (CPU/Memory). |
| besu.securityContext | object | `{}` | Security context applied to the container. |
| besu.service | object | `{"serviceEngineApi":8550,"servicePortRpc":8545,"servicePortWs":8546}` | Service configuration for API ports. |
| besu.service.serviceEngineApi | int | `8550` | Port for the Engine API (e.g., for Sequencers). |
| besu.service.servicePortRpc | int | `8545` | Port for the JSON-RPC API. |
| besu.service.servicePortWs | int | `8546` | Port for the WebSocket API. |
| besu.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service Account configuration. |
| besu.serviceAccount.annotations | object | `{}` | Annotations for the created ServiceAccount. |
| besu.serviceAccount.automount | bool | `true` | Controls if the ServiceAccount token should be automatically mounted. |
| besu.serviceAccount.create | bool | `true` | If true, a ServiceAccount resource will be created. |
| besu.serviceAccount.name | string | `""` | The name of the ServiceAccount to use or create. |
| besu.tolerations | list | `[]` | Tolerations for taints. |
| besu.volumeClaimTemplates | object | `{"accessModes":["ReadWriteOnce"],"size":"50Gi","storageClass":""}` | Persistent Volume Claim template for stateful storage (e.g., blockchain data). |
| besu.volumeClaimTemplates.accessModes | list | `["ReadWriteOnce"]` | List of access modes for the volume (e.g., ReadWriteOnce). |
| besu.volumeClaimTemplates.size | string | `"50Gi"` | Desired size of the persistent volume. |
| besu.volumeClaimTemplates.storageClass | string | `""` | Storage class to use for the volume. |
| besu.volumeMounts | list | `[]` | List of volume mounts for the container. |
| besu.volumes | list | `[]` | List of additional volumes defined at the Pod level. |
| besu.vpa | object | `{"enabled":false,"resourcePolicy":{"containerPolicies":{"controlledResources":["cpu","memory"],"maxAllowed":{"cpu":"4","memory":"8Gi"},"minAllowed":{"cpu":"100m","memory":"512Mi"}}},"updateMode":"Auto"}` | Vertical Pod Autoscaler configuration |
| besu.vpa.enabled | bool | `false` | Enable or disable VPA |
| besu.vpa.resourcePolicy | object | `{"containerPolicies":{"controlledResources":["cpu","memory"],"maxAllowed":{"cpu":"4","memory":"8Gi"},"minAllowed":{"cpu":"100m","memory":"512Mi"}}}` | Resource policy configuration |
| besu.vpa.resourcePolicy.containerPolicies | object | `{"controlledResources":["cpu","memory"],"maxAllowed":{"cpu":"4","memory":"8Gi"},"minAllowed":{"cpu":"100m","memory":"512Mi"}}` | Container policies |
| besu.vpa.resourcePolicy.containerPolicies.controlledResources | list | `["cpu","memory"]` | Resources to be controlled by VPA |
| besu.vpa.resourcePolicy.containerPolicies.maxAllowed | object | `{"cpu":"4","memory":"8Gi"}` | Maximum allowed resources |
| besu.vpa.resourcePolicy.containerPolicies.minAllowed | object | `{"cpu":"100m","memory":"512Mi"}` | Minimum allowed resources |
| besu.vpa.updateMode | string | `"Auto"` | Update mode for VPA (Off, Initial, Recreate, Auto) |
| ethstats.affinity | object | `{}` | Pod affinity settings. |
| ethstats.httpRoute | object | `{"annotations":{},"enabled":false,"hostnames":[],"parentRefs":[{"name":"gateway","sectionName":"http"}],"rules":[{"matches":[{"path":{"type":"PathPrefix","value":"/headers"}}]}]}` | Kubernetes Gateway API HttpRoute configuration (if using the Gateway API). |
| ethstats.httpRoute.annotations | object | `{}` | Annotations for the HttpRoute resource. |
| ethstats.httpRoute.enabled | bool | `false` | Enable or disable HttpRoute creation. |
| ethstats.httpRoute.hostnames | list | `[]` | List of hostnames the route should match. |
| ethstats.httpRoute.parentRefs | list | `[{"name":"gateway","sectionName":"http"}]` | List of parent Gateways this route is attached to. |
| ethstats.httpRoute.rules | list | `[{"matches":[{"path":{"type":"PathPrefix","value":"/headers"}}]}]` | Routing rules. |
| ethstats.httpRoute.rules[0].matches[0].path.type | string | `"PathPrefix"` | Type of path matching (e.g., PathPrefix). |
| ethstats.httpRoute.rules[0].matches[0].path.value | string | `"/headers"` | The path value to match. |
| ethstats.image | object | `{"pullPolicy":"IfNotPresent","repository":"consensys/linea-ethstats-server","tag":"7422b2a-1730387766"}` | Docker image settings for Ethstats. |
| ethstats.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. 'IfNotPresent' is typical for production. |
| ethstats.image.repository | string | `"consensys/linea-ethstats-server"` | Docker repository path for the Ethstats image. |
| ethstats.image.tag | string | `"7422b2a-1730387766"` | Specific Docker image tag (version) to use. |
| ethstats.imagePullSecrets | list | `[]` | List of secrets used for pulling images from private registries. |
| ethstats.livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":3000},"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration. |
| ethstats.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the probe to be considered failed. |
| ethstats.livenessProbe.httpGet | object | `{"path":"/","port":3000}` | HTTP GET action for the probe. |
| ethstats.livenessProbe.httpGet.path | string | `"/"` | Path to check. |
| ethstats.livenessProbe.httpGet.port | int | `3000` | Port to check. |
| ethstats.livenessProbe.initialDelaySeconds | int | `10` | Number of seconds after the container has started before liveness probes are initiated. |
| ethstats.livenessProbe.periodSeconds | int | `10` | How often to perform the probe (seconds). |
| ethstats.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed. |
| ethstats.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out. |
| ethstats.name | string | `"ethstats"` | The component name |
| ethstats.nodeSelector | object | `{}` | Node selection constraints. |
| ethstats.podAnnotations | object | `{}` | Annotations to add to the Pod metadata. |
| ethstats.podLabels | object | `{}` | Labels to add to the Pod metadata. |
| ethstats.podSecurityContext | object | `{}` | Security context applied to the Pod. |
| ethstats.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/","port":3000},"initialDelaySeconds":5,"periodSeconds":5,"successThreshold":1,"timeoutSeconds":1}` | Readiness probe configuration. |
| ethstats.readinessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the probe to be considered failed. |
| ethstats.readinessProbe.httpGet | object | `{"path":"/","port":3000}` | HTTP GET action for the probe. |
| ethstats.readinessProbe.httpGet.path | string | `"/"` | Path to check. |
| ethstats.readinessProbe.httpGet.port | int | `3000` | Port to check. |
| ethstats.readinessProbe.initialDelaySeconds | int | `5` | Number of seconds after the container has started before liveness probes are initiated. |
| ethstats.readinessProbe.periodSeconds | int | `5` | How often to perform the probe (seconds). |
| ethstats.readinessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed. |
| ethstats.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out. |
| ethstats.replicaCount | int | `1` | Number of desired replicas for the deployment. |
| ethstats.resources | object | `{}` | Resource limits and requests (CPU/Memory). |
| ethstats.securityContext | object | `{}` | Security context applied to the container. |
| ethstats.service | object | `{"port":3000,"type":"ClusterIP"}` | Service configuration for the Ethstats dashboard. |
| ethstats.service.port | int | `3000` | Service port for Ethstats. |
| ethstats.service.type | string | `"ClusterIP"` | Kubernetes Service type (e.g., ClusterIP, NodePort, LoadBalancer). |
| ethstats.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service Account configuration. |
| ethstats.serviceAccount.annotations | object | `{}` | Annotations for the created ServiceAccount. |
| ethstats.serviceAccount.automount | bool | `true` | Controls if the ServiceAccount token should be automatically mounted. |
| ethstats.serviceAccount.create | bool | `true` | If true, a ServiceAccount resource will be created. |
| ethstats.serviceAccount.name | string | `""` | The name of the ServiceAccount to use or create. |
| ethstats.tolerations | list | `[]` | Tolerations for taints. |
| ethstats.volumeMounts | list | `[]` | List of volume mounts for the container. |
| ethstats.volumes | list | `[]` | List of additional volumes defined at the Pod level. |
| fullnameOverride | string | `""` | Used to override the full deployment name. Overrides the chart name and release name. |
| maru.affinity | object | `{}` | Pod affinity settings. |
| maru.containerPorts | object | `{"api":8080,"metrics":9547}` | Container port mappings. |
| maru.containerPorts.api | int | `8080` | Internal container port for the API. |
| maru.containerPorts.metrics | int | `9547` | Internal container port for metrics (Prometheus). |
| maru.image | object | `{"pullPolicy":"IfNotPresent","repository":"consensys/maru","tag":"0f6dc85"}` | Docker image settings for Maru. |
| maru.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. 'IfNotPresent' is typical for production. |
| maru.image.repository | string | `"consensys/maru"` | Docker repository path for the Maru image. |
| maru.image.tag | string | `"0f6dc85"` | Specific Docker image tag (version) to use. |
| maru.imagePullSecrets | list | `[]` | List of secrets used for pulling images from private registries. |
| maru.livenessProbe | object | `{}` | Liveness probe configuration. |
| maru.metrics | object | `{"enabled":false,"service":{"servicePort":9547,"type":"ClusterIP"},"serviceMonitor":{"enabled":false}}` | Metrics configuration. |
| maru.metrics.enabled | bool | `false` | Enable or disable Prometheus metrics endpoint. |
| maru.metrics.service | object | `{"servicePort":9547,"type":"ClusterIP"}` | Service definition for the metrics endpoint. |
| maru.metrics.service.servicePort | int | `9547` | Metrics service port. |
| maru.metrics.service.type | string | `"ClusterIP"` | Kubernetes Service type (e.g., ClusterIP, NodePort, LoadBalancer). |
| maru.metrics.serviceMonitor | object | `{"enabled":false}` | Prometheus ServiceMonitor configuration (requires prometheus-operator). |
| maru.metrics.serviceMonitor.enabled | bool | `false` | Enable or disable ServiceMonitor creation. |
| maru.name | string | `"maru"` | The component name |
| maru.nodeSelector | object | `{}` | Node selection constraints. |
| maru.podAnnotations | object | `{}` | Annotations to add to the Pod metadata. |
| maru.podLabels | object | `{}` | Labels to add to the Pod metadata. |
| maru.podSecurityContext | object | `{}` | Security context applied to the Pod. |
| maru.readinessProbe | object | `{}` | Readiness probe configuration. |
| maru.resources | object | `{}` | Resource limits and requests (CPU/Memory). |
| maru.secret | object | `{"key":""}` | Internal secret configuration for Maru. |
| maru.secret.key | string | `""` | Key for Maru's specific secret. |
| maru.securityContext | object | `{}` | Security context applied to the container. |
| maru.service | object | `{"servicePortApi":8080}` | Service configuration for API ports. |
| maru.service.servicePortApi | int | `8080` | Service port for the API. |
| maru.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service Account configuration. |
| maru.serviceAccount.annotations | object | `{}` | Annotations for the created ServiceAccount. |
| maru.serviceAccount.automount | bool | `true` | Controls if the ServiceAccount token should be automatically mounted. |
| maru.serviceAccount.create | bool | `true` | If true, a ServiceAccount resource will be created. |
| maru.serviceAccount.name | string | `""` | The name of the ServiceAccount to use or create. |
| maru.tolerations | list | `[]` | Tolerations for taints. |
| maru.volumeClaimTemplates | object | `{"accessModes":["ReadWriteOnce"],"size":"100Gi","storageClass":""}` | Persistent Volume Claim template for stateful storage. |
| maru.volumeClaimTemplates.accessModes | list | `["ReadWriteOnce"]` | List of access modes for the volume (e.g., ReadWriteOnce). |
| maru.volumeClaimTemplates.size | string | `"100Gi"` | Desired size of the persistent volume. |
| maru.volumeClaimTemplates.storageClass | string | `""` | Storage class to use for the volume. |
| maru.volumeMounts | list | `[]` | List of volume mounts for the container. |
| maru.volumes | list | `[]` | List of additional volumes defined at the Pod level. |
| maru.vpa | object | `{"enabled":false,"resourcePolicy":{"containerPolicies":{"controlledResources":["cpu","memory"],"maxAllowed":{"cpu":"4","memory":"8Gi"},"minAllowed":{"cpu":"100m","memory":"512Mi"}}},"updateMode":"Auto"}` | Vertical Pod Autoscaler configuration |
| maru.vpa.enabled | bool | `false` | Enable or disable VPA |
| maru.vpa.resourcePolicy | object | `{"containerPolicies":{"controlledResources":["cpu","memory"],"maxAllowed":{"cpu":"4","memory":"8Gi"},"minAllowed":{"cpu":"100m","memory":"512Mi"}}}` | Resource policy configuration |
| maru.vpa.resourcePolicy.containerPolicies | object | `{"controlledResources":["cpu","memory"],"maxAllowed":{"cpu":"4","memory":"8Gi"},"minAllowed":{"cpu":"100m","memory":"512Mi"}}` | Container policies |
| maru.vpa.resourcePolicy.containerPolicies.controlledResources | list | `["cpu","memory"]` | Resources to be controlled by VPA |
| maru.vpa.resourcePolicy.containerPolicies.maxAllowed | object | `{"cpu":"4","memory":"8Gi"}` | Maximum allowed resources |
| maru.vpa.resourcePolicy.containerPolicies.minAllowed | object | `{"cpu":"100m","memory":"512Mi"}` | Minimum allowed resources |
| maru.vpa.updateMode | string | `"Auto"` | Update mode for VPA (Off, Initial, Recreate, Auto) |
| nameOverride | string | `""` | Used to override the deployment name. Overrides the chart name. |
| secret.ws_secret | string | `""` | Secret key for Ethstats WebSocket connections |
| sender.affinity | object | `{}` | Pod affinity settings. |
| sender.enabled | bool | `false` | If true, enable the Consensys Sender |
| sender.image | object | `{"pullPolicy":"IfNotPresent","repository":"public.ecr.aws/j0t0w2r4/consensys-sender","tag":""}` | Docker image settings for Sender. |
| sender.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. 'IfNotPresent' is typical for production. |
| sender.image.repository | string | `"public.ecr.aws/j0t0w2r4/consensys-sender"` | Docker repository path for the Consensys Sender image. |
| sender.image.tag | string | `""` | Specific Docker image tag (version) to use. |
| sender.imagePullSecrets | list | `[]` | List of secrets used for pulling images from private registries. |
| sender.livenessProbe | object | `{}` | Liveness probe configuration. |
| sender.name | string | `"sender"` | The component name |
| sender.nodeSelector | object | `{}` | Node selection constraints. |
| sender.podAnnotations | object | `{}` | Annotations to add to the Pod metadata. |
| sender.podLabels | object | `{}` | Labels to add to the Pod metadata. |
| sender.podSecurityContext | object | `{}` | Security context applied to the Pod. |
| sender.readinessProbe | object | `{}` | Readiness probe configuration. |
| sender.replicaCount | int | `1` | Number of desired replicas for the deployment. |
| sender.resources | object | `{}` | Resource limits and requests (CPU/Memory). |
| sender.secret | object | `{"private_key":""}` | Internal secret configuration for Sender. |
| sender.secret.private_key | string | `""` | Private Key for the Sender account |
| sender.securityContext | object | `{}` | Security context applied to the container. |
| sender.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service Account configuration. |
| sender.serviceAccount.annotations | object | `{}` | Annotations for the created ServiceAccount. |
| sender.serviceAccount.automount | bool | `true` | Controls if the ServiceAccount token should be automatically mounted. |
| sender.serviceAccount.create | bool | `true` | If true, a ServiceAccount resource will be created. |
| sender.serviceAccount.name | string | `""` | The name of the ServiceAccount to use or create. |
| sender.tolerations | list | `[]` | Tolerations for taints. |
| sender.volumeMounts | list | `[]` | List of volume mounts for the container. |
| sender.volumes | list | `[]` | List of additional volumes defined at the Pod level. |
| sequencer.affinity | object | `{}` | Pod affinity settings. |
| sequencer.containerPorts | object | `{"engine":8550,"eth":8545,"metrics":9547,"p2p":30303}` | Container port mappings. |
| sequencer.containerPorts.engine | int | `8550` | Internal container port for the Engine API. |
| sequencer.containerPorts.eth | int | `8545` | Internal container port for the Execution API (eth). |
| sequencer.containerPorts.metrics | int | `9547` | Internal container port for metrics (Prometheus). |
| sequencer.containerPorts.p2p | int | `30303` | Internal container port for P2P networking. |
| sequencer.image | object | `{"pullPolicy":"IfNotPresent","repository":"consensys/linea-besu-package","tag":"beta-v4.0-rc20-20251104100707-3294a02"}` | Docker image settings for the Sequencer client (Besu package). |
| sequencer.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. 'IfNotPresent' is typical for production. |
| sequencer.image.repository | string | `"consensys/linea-besu-package"` | Docker repository path for the Sequencer image. |
| sequencer.image.tag | string | `"beta-v4.0-rc20-20251104100707-3294a02"` | Specific Docker image tag (version) to use. |
| sequencer.imagePullSecrets | list | `[]` | List of secrets used for pulling images from private registries. |
| sequencer.livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/liveness","port":8545},"initialDelaySeconds":180,"periodSeconds":60,"successThreshold":1,"timeoutSeconds":1}` | Liveness probe configuration. |
| sequencer.livenessProbe.failureThreshold | int | `3` | Minimum consecutive failures for the probe to be considered failed. |
| sequencer.livenessProbe.httpGet | object | `{"path":"/liveness","port":8545}` | HTTP GET action for the probe. |
| sequencer.livenessProbe.httpGet.path | string | `"/liveness"` | Path to check. |
| sequencer.livenessProbe.httpGet.port | int | `8545` | Port to check. |
| sequencer.livenessProbe.initialDelaySeconds | int | `180` | Number of seconds after the container has started before liveness probes are initiated. |
| sequencer.livenessProbe.periodSeconds | int | `60` | How often to perform the probe (seconds). |
| sequencer.livenessProbe.successThreshold | int | `1` | Minimum consecutive successes for the probe to be considered successful after having failed. |
| sequencer.livenessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out. |
| sequencer.metrics | object | `{"enabled":false,"service":{"servicePort":9547,"type":"ClusterIP"},"serviceMonitor":{"enabled":false}}` | Metrics configuration. |
| sequencer.metrics.enabled | bool | `false` | Enable or disable Prometheus metrics endpoint. |
| sequencer.metrics.service | object | `{"servicePort":9547,"type":"ClusterIP"}` | Service definition for the metrics endpoint. |
| sequencer.metrics.service.servicePort | int | `9547` | Metrics service port. |
| sequencer.metrics.service.type | string | `"ClusterIP"` | Kubernetes Service type (e.g., ClusterIP, NodePort, LoadBalancer). |
| sequencer.metrics.serviceMonitor | object | `{"enabled":false}` | Prometheus ServiceMonitor configuration (requires prometheus-operator). |
| sequencer.metrics.serviceMonitor.enabled | bool | `false` | Enable or disable ServiceMonitor creation. |
| sequencer.name | string | `"sequencer"` | The component name, used for internal identification and potentially labels/selectors. |
| sequencer.nodeSelector | object | `{}` | Node selection constraints. |
| sequencer.podAnnotations | object | `{}` | Annotations to add to the Pod metadata. |
| sequencer.podLabels | object | `{}` | Labels to add to the Pod metadata. |
| sequencer.podSecurityContext | object | `{}` | Security context applied to the Pod. |
| sequencer.readinessProbe | object | `{}` | Readiness probe configuration. |
| sequencer.resources | object | `{}` | Resource limits and requests (CPU/Memory). |
| sequencer.secret | object | `{"key":""}` | Internal secret configuration for the Sequencer. |
| sequencer.secret.key | string | `""` | Key for Sequencer's specific secret. |
| sequencer.securityContext | object | `{}` | Security context applied to the container. |
| sequencer.service | object | `{"serviceEngineApi":8550,"serviceEthApi":8545,"servicePortP2p":30303}` | Service configuration for API ports. |
| sequencer.service.serviceEngineApi | int | `8550` | Port for the Engine API. |
| sequencer.service.serviceEthApi | int | `8545` | Port for the Execution API (eth). |
| sequencer.service.servicePortP2p | int | `30303` | Port for P2P networking. |
| sequencer.serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service Account configuration. |
| sequencer.serviceAccount.annotations | object | `{}` | Annotations for the created ServiceAccount. |
| sequencer.serviceAccount.automount | bool | `true` | Controls if the ServiceAccount token should be automatically mounted. |
| sequencer.serviceAccount.create | bool | `true` | If true, a ServiceAccount resource will be created. |
| sequencer.serviceAccount.name | string | `""` | The name of the ServiceAccount to use or create. |
| sequencer.tolerations | list | `[]` | Tolerations for taints. |
| sequencer.volumeClaimTemplates | object | `{"accessModes":["ReadWriteOnce"],"size":"50Gi","storageClass":""}` | Persistent Volume Claim template for stateful storage (e.g., blockchain data). |
| sequencer.volumeClaimTemplates.accessModes | list | `["ReadWriteOnce"]` | List of access modes for the volume (e.g., ReadWriteOnce). |
| sequencer.volumeClaimTemplates.size | string | `"50Gi"` | Desired size of the persistent volume. |
| sequencer.volumeClaimTemplates.storageClass | string | `""` | Storage class to use for the volume. |
| sequencer.volumeMounts | list | `[]` | List of volume mounts for the container. |
| sequencer.volumes | list | `[]` | List of additional volumes defined at the Pod level. |
| sequencer.vpa | object | `{"enabled":false,"resourcePolicy":{"containerPolicies":{"controlledResources":["cpu","memory"],"maxAllowed":{"cpu":"4","memory":"8Gi"},"minAllowed":{"cpu":"100m","memory":"512Mi"}}},"updateMode":"Auto"}` | Vertical Pod Autoscaler configuration |
| sequencer.vpa.enabled | bool | `false` | Enable or disable VPA |
| sequencer.vpa.resourcePolicy | object | `{"containerPolicies":{"controlledResources":["cpu","memory"],"maxAllowed":{"cpu":"4","memory":"8Gi"},"minAllowed":{"cpu":"100m","memory":"512Mi"}}}` | Resource policy configuration |
| sequencer.vpa.resourcePolicy.containerPolicies | object | `{"controlledResources":["cpu","memory"],"maxAllowed":{"cpu":"4","memory":"8Gi"},"minAllowed":{"cpu":"100m","memory":"512Mi"}}` | Container policies |
| sequencer.vpa.resourcePolicy.containerPolicies.controlledResources | list | `["cpu","memory"]` | Resources to be controlled by VPA |
| sequencer.vpa.resourcePolicy.containerPolicies.maxAllowed | object | `{"cpu":"4","memory":"8Gi"}` | Maximum allowed resources |
| sequencer.vpa.resourcePolicy.containerPolicies.minAllowed | object | `{"cpu":"100m","memory":"512Mi"}` | Minimum allowed resources |
| sequencer.vpa.updateMode | string | `"Auto"` | Update mode for VPA (Off, Initial, Recreate, Auto) |

---

## 🧪 Testing

Lint the chart:

```sh
helm lint .
```

Render templates for debugging:

```sh
helm template my-linea .
```

---

## 📄 License

This project is licensed under the Apache 2.0 License.
