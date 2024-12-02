#
# Fluent Bit Resources
#

data "kubernetes_namespace" "existing_namespace" {
  metadata {
    name = var.namespace_name
  }
}

resource "kubernetes_namespace" "fluent_bit" {
  metadata {
    name = var.namespace_name
  }

  # Solo aplica si el Namespace no existe
  count = length(data.kubernetes_namespace.existing_namespace.id) == 0 ? 1 : 0
}

resource "helm_release" "fluent_bit" {
  depends_on = [kubernetes_namespace.fluent_bit]

  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = var.chart_version
  namespace  = var.namespace_name

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      request_memory = var.resources["requests"]["memory"],
      limits_memory  = var.resources["limits"]["memory"],
      request_cpu    = var.resources["requests"]["cpu"],
      limits_cpu     = var.resources["limits"]["cpu"]
    })
  ]

  set_sensitive {
    name  = "config.outputs"
    value = local.config_output_literal
  }
}

#
# Walrus Resources
#

locals {
  context = var.context

  config_output_literal = <<EOT
[OUTPUT]
${join("\n", [
  for k, v in var.config_output :
  v != null && v != "" ? "    ${k} ${tostring(v)}" : ""
])}
EOT
}

module "submodule" {
  source = "./modules/submodule"

  message = "Hello, submodule"
}
