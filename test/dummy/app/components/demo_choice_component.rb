# frozen_string_literal: true
# An interactive ViewComponent: naming surface/state/error as keywords opts into
# Surface context, and including the helper gives it the action form builders.
class DemoChoiceComponent < ViewComponent::Base
  include RailsToolViews::SurfacesHelper
  def initialize(title:, options:, surface:, state:, error: nil)
    @title, @options, @surface, @state, @error = title, options, surface, state, error
  end
end
