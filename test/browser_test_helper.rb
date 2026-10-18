# frozen_string_literal: true
abort "Use bin/check-browser for disposable browser tests" unless ENV["RAILS_TOOL_VIEWS_SYSTEM_TEST"] == "1"
require_relative "test_helper"
require "capybara/minitest"
require "selenium-webdriver"

# Selenium's default port probe briefly binds every network interface. Restrict
# this driver-only availability check to loopback, just like the actual server.
module RailsToolViewsLoopbackPortProbe
  def free?(port)
    TCPServer.open("127.0.0.1", port) { true }
  rescue Errno::EADDRINUSE
    false
  end
end
Selenium::WebDriver::PortProber.singleton_class.prepend(RailsToolViewsLoopbackPortProbe)

Capybara.app = Rails.application
Capybara.server = :puma, { Silent: true }
Capybara.server_host = "127.0.0.1"
Capybara.default_max_wait_time = 5
Capybara.save_path = ENV.fetch("BROWSER_ARTIFACTS")
%i[rails_tool_views_chrome rails_tool_views_no_js].each do |driver_name|
Capybara.register_driver driver_name do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  %w[--headless=new --window-size=1440,1000 --disable-background-networking --no-sandbox --disable-dev-shm-usage].each { |arg| options.add_argument(arg) }
  options.add_preference("profile.managed_default_content_settings.javascript", 2) if driver_name == :rails_tool_views_no_js
  options.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"]
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end
end
Capybara.default_driver = :rails_tool_views_chrome

class BrowserTest < ActiveSupport::TestCase
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  setup do
    Rails.application.reloader.prepare!
    # Exercise real form tokens and server-resolved identity in the browser suite.
    ActionController::Base.allow_forgery_protection = true
  end

  teardown do
    begin
      take_screenshot(passed? ? "passed" : "failed")
    rescue StandardError => error
      warn "Browser screenshot unavailable: #{error.class}: #{error.message}"
    ensure
      Capybara.reset_sessions!
      Capybara.current_session.driver.quit
    end
  end

  def mobile_viewport
    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: 390, height: 844, deviceScaleFactor: 1, mobile: true)
  end

  def take_screenshot(label)
    save_screenshot("#{name.gsub(/[^a-zA-Z0-9_-]/, '_')}-#{label}.png")
  end
end
