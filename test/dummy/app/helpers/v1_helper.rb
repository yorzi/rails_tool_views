# frozen_string_literal: true
module V1Helper
  def v1_scope(surface)
    RailsToolViews::Scope.new(actor: surface.actor_ref, tenant: surface.tenant_ref)
  end
  def v1_action_fields(surface, action, arguments = {})
    safe_join([tool_views_action_fields(surface, action)] + arguments.map { |name, value| hidden_field_tag("arguments[#{name}]", value, id: nil) })
  end
  def v1_value(surface, error, field, fallback = nil)
    values = error.is_a?(RailsToolViews::ValidationError) ? error.values : surface.props.fetch("values", {})
    values.fetch(field.to_s, fallback)
  end
  def v1_field_error(error, field)
    error.is_a?(RailsToolViews::ValidationError) && error.fields[field.to_s]
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
