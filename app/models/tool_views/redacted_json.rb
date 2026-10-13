# frozen_string_literal: true
module ToolViews
  # JSON column type whose database bind hides itself from SQL logs. Rails
  # filters binds by attribute name alone, so listing `state` or `result` in the
  # host-wide filter would also redact every host column that shares the name.
  class RedactedJson < ActiveRecord::Type::Json
    class Bind < String
      def inspect
        "[FILTERED]"
      end
      def as_json(*)
        "[FILTERED]"
      end
    end
    def serialize(value)
      json = super
      json && Bind.new(json)
    end
  end
end
