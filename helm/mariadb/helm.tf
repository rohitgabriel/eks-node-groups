resource "helm_release" "mariadatabase" {
  provider  = helm
  name      = "mariadatabase"
  chart     = "mariadb"
  namespace = "default"
  repository = "https://kubernetes-charts.storage.googleapis.com"

  set {
    name  = "mariadbUser"
    value = "foooo"
  }

  set {
    name  = "mariadbPassword"
    value = "qux"
  }
}