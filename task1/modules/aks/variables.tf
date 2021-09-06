# The name of the microservice
variable "ms_name" {}

# The port the microservice listens on
variable "port" {}

# The k8s namespace for the microservice
variable "namespace" {}

# The docker image for the microservice
variable "container_image" {}

variable "replicas" {}

variable "min_replicas" {}

variable "max_replicas" {}

variable "volume_mount" {
  type = list(object({
    name = string
    mount_path = string
  }))
  default = []
}

