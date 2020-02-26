locals {
  recipients_message       = "${length(var.recipients) > 0 ? " @" : ""}${join(" @", var.recipients)}"
  alert_message            = "${length(var.alert_recipients) > 0 ? "{{#is_alert}} @${join(" @", var.alert_recipients)}{{/is_alert}}" : ""}"
  alert_recovery_message   = "${length(var.alert_recipients) > 0 ? "{{#is_alert_recovery}} @${join(" @", var.alert_recipients)}{{/is_alert_recovery}}" : ""}"
  warning_message          = "${length(var.warning_recipients) > 0 ? "{{#is_warning}} @${join(" @", var.warning_recipients)}{{/is_warning}}" : ""}"
  warning_recovery_message = "${length(var.warning_recipients) > 0 ? "{{#is_warning_recovery}} @${join(" @", var.warning_recipients)}{{/is_warning_recovery}}" : ""}"

  full_message = <<EOF
${var.message}
${var.dashboard_id != "" ? "Dashboard: https://app.datadoghq.com/dashboard/${var.dashboard_id}" : ""}
${var.dashboard_id == "" && var.timeboard_id != "" ? "Timeboard: https://app.datadoghq.com/dash/${var.timeboard_id}" : ""}
Related timeboards: https://app.datadoghq.com/dashboard/lists?q=${join("+-+", list(var.product_domain, var.service, var.environment))}
Related monitors: https://app.datadoghq.com/monitors/manage?q=tag%3A%28%22${join("%22%20AND%20%22", local.tags)}%22%29
Notification recipients:${local.recipients_message}${local.alert_message}${local.alert_recovery_message}${local.warning_message}${local.warning_recovery_message}
EOF

  tags = ["product_domain:${var.product_domain}", "service:${var.service}", "environment:${var.environment}"]
}

resource "datadog_monitor" "template" {
  count = "${var.enabled}"

  name = "${var.name}"
  type = "metric alert"

  query            = "${var.query}"
  thresholds       = "${var.thresholds}"
  evaluation_delay = "${var.evaluation_delay}"

  message            = "${local.full_message}"
  escalation_message = "${var.escalation_message}"

  renotify_interval = "${var.renotify_interval}"
  notify_audit      = "${var.notify_audit}"
  include_tags      = "${var.include_tags}"

  tags = "${concat(local.tags, var.tags)}"
}
