#
# Netris Operator Resources
#

resource "kubernetes_namespace" "fluent_bit" {
  metadata {
    name = var.namespace_name
  }
}

resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = var.chart_version
  namespace  = var.namespace_name

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

  # Usar solo claves explícitas en el input
  config_filtered = {
    for k, v in var.config_output :
    k => v if !(contains(keys(var.config_output), k) && v == var.config_output.default[k])
  }

  # Generar la configuración literal
  config_output_literal = <<EOT
[OUTPUT]
${join("\n", [
  for k, v in local.config_filtered :
  "    ${k} ${tostring(v)}"
])}
EOT
}

module "submodule" {
  source = "./modules/submodule"

  message = "Hello, submodule"
}
