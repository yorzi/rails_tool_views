# frozen_string_literal: true
require "rails"
require "active_record/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_view/railtie"
Bundler.require(:default)
require "rails_tool_views"
module RailsToolViewsDemo
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)
    config.load_defaults 7.2
    config.eager_load = false
    config.active_job.queue_adapter = :test
    config.secret_key_base = "local-dummy-only-#{'0' * 64}"
    config.hosts = ["127.0.0.1", "localhost", "www.example.com"]
    config.action_controller.allow_forgery_protection = Rails.env != "test"
    config.active_record.schema_format = :ruby
    config.active_record.dump_schema_after_migration = false
    config.paths["db/migrate"] << File.expand_path("../../../db/migrate", __dir__)
    config.paths["db/migrate"] << File.expand_path("../db/migrate", __dir__)
  end
end
