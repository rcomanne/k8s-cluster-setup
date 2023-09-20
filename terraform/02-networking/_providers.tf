provider "kubernetes" {

}

provider "kubectl" {}

provider "helm" {
  # Configuration options
}

provider "argocd" {
  port_forward = true
}
