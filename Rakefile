# frozen_string_literal: true
require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"
Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.pattern = "test/*_test.rb"
  task.warning = false
end
task default: :test
namespace :test do
  task :prepare do
    ENV["RAILS_ENV"] = "test"
    require_relative "test/dummy/config/environment"
    ActiveRecord::MigrationContext.new(Rails.application.paths["db/migrate"].to_a).migrate
  end
end
task test: "test:prepare"

Rake::TestTask.new("test:adapter") do |task|
  task.libs << "test"
  task.pattern = "test/adapter/*_test.rb"
  task.warning = false
end
task "test:adapter" => "test:prepare"

namespace :demo do
  task :prepare do
    ENV["RAILS_ENV"] = "development"
    require_relative "test/dummy/config/environment"
    ActiveRecord::MigrationContext.new(Rails.application.paths["db/migrate"].to_a).migrate
  end
end

namespace :zeitwerk do
  task :check do
    ENV["RAILS_ENV"] ||= "test"
    require_relative "test/dummy/config/environment"
    require "rails/zeitwerk_checker"
    Rails::ZeitwerkChecker.check
    puts "All is good!"
  end
end

# Browser tests run in a separate process and disposable DB via bin/check-browser.
Rake::TestTask.new("test:browser") do |task|
  task.libs << "test"
  task.pattern = "test/browser/*_test.rb"
  task.warning = false
end
task "test:browser" => "test:prepare"
