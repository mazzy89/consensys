resource "helm_release" "vertical_pod_autoscaler" {
  name             = "vertical-pod-autoscaler"
  chart            = "https://github.com/kubernetes/autoscaler/releases/download/vertical-pod-autoscaler-chart-0.6.0/vertical-pod-autoscaler-0.6.0.tgz"
  namespace        = "kube-system"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 300
}

resource "helm_release" "envoy_gateway" {
  name             = "envoy-gateway"
  repository       = "oci://docker.io/envoyproxy"
  namespace        = "gateway-system"
  chart            = "gateway-helm"
  version          = "v1.6.0"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  timeout          = 300
}
