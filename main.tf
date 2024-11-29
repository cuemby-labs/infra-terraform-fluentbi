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

  # Definir los valores predeterminados explícitamente
  default_config_output = {
    Name              = "http"
    Match             = "*"
    host              = "<victoria-logs-service>.<victoria-logs-service-namespace>.svc.cluster.local"
    port              = "9428"
    uri               = "/insert/jsonline?_stream_fields=stream&_msg_field=log&_time_field=date"
    format            = "json_lines"
    json_date_format  = "iso8601"
    compress          = "gzip"
  }

  # Filtrar claves explícitas
  config_filtered = {
    for k, v in var.config_output :
    k => v if !(contains(keys(local.default_config_output), k) && v == local.default_config_output[k])
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
