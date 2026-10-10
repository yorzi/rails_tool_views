# frozen_string_literal: true
module V1Helper
  def v1_scope(surface)
    ToolViews::Scope.new(actor: surface.actor_ref, tenant: surface.tenant_ref)
  end
  def v1_action_fields(surface, action, arguments = {})
    fields = { action_name: action, base_revision: surface.revision, idempotency_key: SecureRandom.uuid, source_component: surface.component_key }
    safe_join(fields.map { |name, value| hidden_field_tag(name, value) } + arguments.map { |name, value| hidden_field_tag("arguments[#{name}]", value) })
  end
  def v1_value(surface, error, field, fallback = nil)
    values = error.is_a?(ToolViews::ValidationError) ? error.values : surface.props.fetch("values", {})
    values.fetch(field.to_s, fallback)
  end
  def v1_field_error(error, field)
    error.is_a?(ToolViews::ValidationError) && error.fields[field.to_s]
  end
  def v1_input_attributes(surface, error, field)
    id = "#{surface.dom_id}_#{field}"
    invalid = v1_field_error(error, field)
    { id: id, aria: { invalid: invalid ? "true" : nil, describedby: invalid ? "#{id}_error" : nil } }
  end
  def v1_error_message(surface, error, field)
    message = v1_field_error(error, field)
    content_tag(:p, message, id: "#{surface.dom_id}_#{field}_error", class: "v1-field-error") if message
  end
end
