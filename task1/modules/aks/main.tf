#
# Kubernetes Service
#
resource "kubernetes_service" "this" {
  metadata {
    name = "${var.ms_name}-svc"
    namespace = var.namespace
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-internal" = true
    }
  }
  spec {
    selector = {
      app = "${var.ms_name}-dep"
    }
    #session_affinity = "ClientIP"
    port {
      port        = var.port
      target_port = var.port
    }
    type = "LoadBalancer"
  }
}

#
# Kubernetes Deployment
#
resource "kubernetes_deployment" "this" {

  metadata {
      name = "${var.ms_name}-dep"
      namespace = var.namespace
      labels = {
        app = "${var.ms_name}-dep"
      }
    }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "${var.ms_name}-dep"
      }
    }

    template {
      metadata {
        labels = {
          app = "${var.ms_name}-dep"
          role = "rolling-update"
        }
      }

      spec {
        container {
          image = var.container_image
          name  = var.ms_name
          port {
            container_port = var.port
            host_port = var.port
          }
          resources {
            limits {
              cpu    = "1"
              memory = "4096Mi"
            }
            requests {
              cpu    = "0.5"
              memory = "1024Mi"
            }
          }

        volume_mount {
          name = "azure"
          mount_path = "/logs"
        }
        
          #readiness_probe {}
        
          # liveness_probe {
          #   http_get {
          #     path = "/nginx_status"
          #     port = 80

          #     http_header {
          #       name  = "X-Custom-Header"
          #       value = "Awesome"
          #     }
          #   }

          #   initial_delay_seconds = 3
          #   period_seconds        = 3
          # }
       
}
        volume {
          name = "azure"
          azure_file {
            secret_name = "hemi-azure-secret"
            share_name = "hemi-pv-share"
            read_only = false
          }
        }

        image_pull_secrets {
          name = "orxhemiacrreg-secret"
        }
    }
    
    }
    strategy {
        type = "RollingUpdate"
        rolling_update {
          max_surge = 1
          max_unavailable = 0
        }
      }
  }
}

#
# Kubernetes Pod Autoscaler
#
resource "kubernetes_horizontal_pod_autoscaler" "kube-deployment-hpa-provider-ms" {
  metadata {
    name = "${var.ms_name}-ms-hpa"
  }
  spec {
    max_replicas = var.max_replicas
    min_replicas = var.min_replicas
    scale_target_ref {
      kind = "Deployment"
      name = "${var.ms_name}-dep"
    }
  }
}
