# frozen_string_literal: true
require_relative "test_helper"
require "tmpdir"
require "rails/generators"

class ComponentGeneratorTest < ActiveSupport::TestCase
  def generate(root, name, *options)
    generator = Rails::Generators.find_by_namespace("component", "rails_tool_views")
    assert generator, "rails_tool_views:component is discoverable"
    generator.new([name], { force: options.include?("--force") }, destination_root: root).invoke_all
  end

  test "generated registration fails closed and rejects extra properties" do
    Dir.mktmpdir do |root|
      generate(root, "review_card")
      load File.join(root, "config/rails_tool_views/components/review_card.rb")
      assert_error("NOT_ALLOWED") { RailsToolViews.present(:review_card, props: { title: "Review" }, scope: scope) }
      definition = RailsToolViews.registry.fetch(:review_card)
      assert_error("INVALID_PROPS") { definition.schema.validate!({ "title" => "Review", "trusted" => true }) }
      assert_error("INVALID_ARGUMENTS") { definition.actions.fetch("set_value").schema.validate!({ "value" => "ok", "admin" => true }, code: "INVALID_ARGUMENTS") }
      registration = File.join(root, "config/rails_tool_views/components/review_card.rb")
      original = File.read(registration)
      # Authorize presentation only: the separate action policy must still deny.
      File.write(registration, original.sub("policy: ->(_access) { false }", "policy: ->(_access) { true }"))
      RailsToolViews.reset_registry!
      load registration
      surface = RailsToolViews.present(:review_card, props: { title: "Review" }, scope: scope)
      assert_error("NOT_ALLOWED") do
        RailsToolViews.dispatch(surface.id, scope: scope, action: "set_value", arguments: { value: "no write" },
          base_revision: 1, idempotency_key: "generator-denied")
      end
      assert_equal 1, surface.reload.revision
      File.write(registration, original)
      assert_empty definition.expose_to
      assert File.file?(File.join(root, "test/rails_tool_views/components/review_card_test.rb"))
      assert_includes File.read(File.join(root, "app/views/rails_tool_views/components/_review_card.html.erb")), 'props.fetch("title")'
      # Reloading several definitions must retain every component and host configuration.
      generate(root, "other_card")
      2.times do
        RailsToolViews.reset_registry!
        Dir[File.join(root, "config/rails_tool_views/components/*.rb")].sort.each { |file| load file }
        assert RailsToolViews.registry.fetch(:review_card)
        assert RailsToolViews.registry.fetch(:other_card)
      end
    end
  end

  test "unsafe names and any existing destination fail before writing" do
    ["../escape", "nested/card", "CamelCase", "bad-name", "a" * 65].each do |name|
      Dir.mktmpdir do |root|
        assert_raises(Thor::Error) { generate(root, name) }
        assert_empty Dir[File.join(root, "**/*")]
      end
    end
    Dir.mktmpdir do |root|
      partial = File.join(root, "app/views/rails_tool_views/components/_review_card.html.erb")
      FileUtils.mkdir_p(File.dirname(partial))
      File.write(partial, "host content")
      assert_raises(Thor::Error) { generate(root, "review_card", "--force") }
      assert_equal "host content", File.read(partial)
      refute File.exist?(File.join(root, "config/rails_tool_views/components/review_card.rb"))
    end
  end

  test "symlink destinations cannot write outside the host" do
    Dir.mktmpdir do |root|
      Dir.mktmpdir do |outside|
        File.symlink(outside, File.join(root, "config"))
        assert_raises(Thor::Error) { generate(root, "review_card") }
        assert_empty Dir[File.join(outside, "**/*")]
      end
    end
  end
end
