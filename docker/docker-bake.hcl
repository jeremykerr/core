
// Default platforms for multi-arch build
variable "PLATFORMS" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "IMAGE_TAG" {
  default = "latest"
}

// Default target stage
variable "TARGET" {
  default = ""
}

group "default" {
  targets = ["image"]
}

// Metadata action for use with docker/metadata-action in GHA
target "docker-metadata-action" {}

target "build-common" {
  platforms = "${PLATFORMS}"
  cache-from = ["type=local,src=/tmp/docker-cache", "type=gha,scope=local-dev"]
  cache-to = ["type=local,dest=/tmp/docker-cache,mode=min"]
}

target "proxy" {
    context = "./platform/proxy"
    dockerfile = "../../docker/Dockerfile.proxy"
    inherits = ["build-common"]
    output = ["type=docker"]
    tags = ["core-proxy:${IMAGE_TAG}"]
}

target "image" {
  inherits = ["build-common", "docker-metadata-action"]
}
