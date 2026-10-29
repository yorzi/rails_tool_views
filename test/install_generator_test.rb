# frozen_string_literal: true
require_relative "test_helper"
require "tmpdir"
require "rails/generators"

class InstallGeneratorTest < ActiveSupport::TestCase
  DEFAULT_MOUNT = 'mount RailsToolViews::Engine => "/rails_tool_views", as: :rails_tool_views'

  def install(root, behavior: :invoke)
    generator = Rails::Generators.find_by_namespace("install", "rails_tool_views")
    capture_io { generator.new([], { skip: true }, destination_root: root, behavior: behavior).invoke_all }
  end

  def host(routes)
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, "config"))
      File.write(File.join(root, "config/routes.rb"), "Rails.application.routes.draw do\n#{routes}end\n")
      yield root, File.join(root, "config/routes.rb")
    end
  end

  # Draws the host file into its own route set, as booting the host would.
  def draw(routes_file)
    set = ActionDispatch::Routing::RouteSet.new
    eval(File.read(routes_file).sub("Rails.application.routes", "set"), binding, routes_file)
    set
  end

  test "a fresh host gets one default mount, also after a rerun" do
    host("") do |root, routes|
      2.times { install(root) }
      assert_equal 1, File.read(routes).scan(DEFAULT_MOUNT).length
      assert_equal "/rails_tool_views", draw(routes).named_routes.get(:rails_tool_views).path.spec.to_s
    end
  end

  test "an existing mount under its own path is kept and still loads" do
    [%(  mount RailsToolViews::Engine => "/product_surfaces", as: :rails_tool_views\n),
      %(  mount ::RailsToolViews::Engine, at: "/product_surfaces"\n)].each do |mount|
      host(mount) do |root, routes|
        original = File.read(routes)
        output = install(root).first
        assert_equal original, File.read(routes)
        assert_includes output, "already mounts RailsToolViews::Engine"
        assert_equal "/product_surfaces", draw(routes).named_routes.get(:rails_tool_views).path.spec.to_s
      end
    end
  end

  test "a commented-out mount does not count" do
    host(%(  # mount RailsToolViews::Engine => "/old", as: :rails_tool_views\n)) do |root, routes|
      install(root)
      assert_includes File.read(routes), "  #{DEFAULT_MOUNT}\n"
    end
  end

  test "destroy still removes the default mount" do
    host("") do |root, routes|
      install(root)
      install(root, behavior: :revoke)
      refute_includes File.read(routes), DEFAULT_MOUNT
    end
  end
end
