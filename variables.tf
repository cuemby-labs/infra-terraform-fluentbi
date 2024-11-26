#
# Fluent-Bit Operator
#

variable "namespace_name" {
  description = "The name of the Kubernetes namespace."
  type        = string
  default     = "fluent-bit"
}

variable "chart_version" {
  description = "The version of the fluent-bit Helm release chart."
  type        = string
  default     = "0.48.2"
}

variable "config_output" {
  description = "YAML configuration for the Fluent Bit output plugin."
  type        = string
  default     = <<EOT
[OUTPUT]
    Name http
    Match *
    host <victoria-logs-service>.<victoria-logs-service-namespace>.svc.cluster.local
    port 9428
    uri /insert/jsonline?_stream_fields=stream&_msg_field=log&_time_field=date
    format json_lines
    json_date_format iso8601
    compress gzip
EOT
}

#
# Contextual Fields
#

variable "context" {
  description = <<-EOF
Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field.

Examples:
```
context:
  project:
    name: string
    id: string
  environment:
    name: string
    id: string
  resource:
    name: string
    id: string
```
EOF
  type        = map(any)
  default     = {}
}
