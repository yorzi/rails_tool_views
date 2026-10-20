# frozen_string_literal: true
# Run immutable released runtimes and the working runtime in separate processes
# against one disposable host database. No provider, server or user's database.
require "bundler/setup"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"
root = File.expand_path("..", __dir__)
%w[v0.2.0 v0.3.0].each do |previous_tag|
  Dir.mktmpdir("rails-tool-views-upgrade-") do |temporary|
    previous = File.join(temporary, "old")
    FileUtils.mkdir_p(previous)
    archive, status = Open3.capture2("git", "-C", root, "archive", previous_tag)
    abort "The immutable #{previous_tag} fixture is required" unless status.success?
    Open3.popen3("tar", "-xf", "-", "-C", previous) do |input, _out, error, process|
      input.binmode.write(archive)
      input.close
      abort error.read unless process.value.success?
    end
    host = File.join(temporary, "host")
    FileUtils.mkdir_p(File.join(host, "config"))
    FileUtils.mkdir_p(File.join(host, "db", "migrate"))
    File.write(File.join(host, "config/database.yml"), "test:\n  adapter: sqlite3\n  database: #{host}/test.sqlite3\n")
    File.write(File.join(host, "config/routes.rb"), "Rails.application.routes.draw {}")
    FileUtils.cp(Dir[File.join(previous, "db/migrate/*.rb")], File.join(host, "db/migrate"))
    %w[old new].each do |phase|
      code = phase == "old" ? previous : root
      success = system(RbConfig.ruby, File.join(root, "scripts/support/upgrade_host.rb"), code, host, phase)
      abort "Upgrade #{phase} phase failed" unless success
    end
  end
end
