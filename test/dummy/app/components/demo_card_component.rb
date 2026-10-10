# frozen_string_literal: true
class DemoCardComponent < ViewComponent::Base
  def initialize(title:, options:)
    @title, @options = title, options
  end
  def call
    content_tag(:div) do
      safe_join([content_tag(:h2, @title), content_tag(:p, "Trusted ViewComponent · #{@options.length} options")])
    end
  end
end
