# frozen_string_literal: true
# Execute the marked tutorial blocks from the published sources against a
# temporary database, not the developer's demo database.
require "tmpdir"
require "fileutils"
Dir.mktmpdir("rails-tool-views-docs-") do |temporary|
  ENV["RAILS_ENV"] = "test"
  ENV["DATABASE_URL"] = "sqlite3:#{temporary}/examples.sqlite3"
  require "bundler/setup"
  require_relative "../test/support/offline"
  require_relative "../test/dummy/config/environment"
  require "rails_tool_views/adapters/ruby_llm" if ENV["DOCS_ADAPTER"] == "1"
  ActiveRecord::Migration.verbose = false
  ActiveRecord::MigrationContext.new(Rails.application.paths["db/migrate"].to_a).migrate
  RailsToolViews.reset!
  docs = File.expand_path("../docs/site", __dir__)
  snippets = Dir["#{docs}/_*/**/*.md"].flat_map do |path|
    File.read(path).scan(/```ruby\n(# docs-example: ([\w-]+)\n.*?)\n```/m).map { |code, name| [name, [code, path]] }
  end.to_h
  context = binding
  %w[registration lifecycle dispatch error notice].each do |name|
    code, path = snippets.fetch(name)
    eval(code, context, path)
  end
  raise "Saved selection differs" unless eval('surface.reload.state.fetch("selected") == "compare" && surface.revision == 2', context)
  raise "Documented error output differs" unless eval('error.message == "Only two left."', context)
  raise "Documented notice differs" unless eval('transition.notice == "Selection saved." && transition.state == { selected: "compare" }', context)
  replay_code, = snippets.fetch("dispatch")
  eval(replay_code, context)
  raise "Replay duplicated an action" unless RailsToolViews::ActionExecution.count == 1
  if ENV["DOCS_ADAPTER"] == "1"
    code, path = snippets.fetch("tool")
    eval(code, context, path)
    raise "Wrong catalog" unless eval('present_ui.parameters_schema["properties"]["component"]["enum"] == ["choice_card"]', context)
  end
  guide = File.read("#{docs}/_getting_started/getting-started.md")
  partial = guide.match(/```erb\n(.*?)\n```/m)[1]
  FileUtils.mkdir_p("#{temporary}/views/choices")
  File.write("#{temporary}/views/choices/_card.html.erb", partial)
  controller = ApplicationController.new
  controller.prepend_view_path("#{temporary}/views")
  controller.request = ActionDispatch::TestRequest.create
  controller.response = ActionDispatch::TestResponse.new
  html = RailsToolViews.render(eval("surface", context), view_context: controller.view_context, scope: eval("scope", context))
  raise "Tutorial form failed" unless html.include?("Next step") && html.include?("arguments[key]") && html.include?("select_option")
  close_code, close_path = snippets.fetch("close-surface")
  eval(close_code, context, close_path)
  raise "Documented closure failed" unless eval('closed.closed? && closed.revision == 3', context)
  require "active_support/testing/time_helpers"
  Object.new.extend(ActiveSupport::Testing::TimeHelpers).travel_to(31.days.from_now) do
    preview_code, preview_path = snippets.fetch("retention-preview")
    eval(preview_code, context, preview_path)
    raise "Documented preview differs" unless eval('summary == { examined: 1, eligible: 1, purged: 0, protected: 0, dry_run: true }', context)
    raise "Preview deleted receipts" unless RailsToolViews::ActionExecution.count == 1
    apply_code, apply_path = snippets.fetch("retention-apply")
    eval(apply_code, context, apply_path)
    raise "Documented cleanup failed" unless eval('summary[:purged] == 1 && closed.reload.purged? && closed.props.empty?', context)
  end
  puts "DOCS_EXAMPLES_PASS: registration, persistence, dispatch, replay, notice, error wording, ERB form, close, retention preview/apply#{', optional tool catalog' if ENV['DOCS_ADAPTER'] == '1'}"
end
