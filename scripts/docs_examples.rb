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
  %w[registration lifecycle dispatch error].each do |name|
    code, path = snippets.fetch(name)
    eval(code, context, path)
  end
  raise "Saved selection differs" unless eval('surface.reload.state.fetch("selected") == "compare" && surface.revision == 2', context)
  raise "Documented error output differs" unless eval('error.message == "Only two left."', context)
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
  puts "DOCS_EXAMPLES_PASS: registration, persistence, dispatch, replay, error wording, ERB form#{', optional tool catalog' if ENV['DOCS_ADAPTER'] == '1'}"
end
