# frozen_string_literal: true
module RailsToolViews
  VERSION = "0.2.0.pre.v2"
end

# Compatibility with the unpublished ToolViews package. One module, one registry.
ToolViews = RailsToolViews unless defined?(ToolViews)
