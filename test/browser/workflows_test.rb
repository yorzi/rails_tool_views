# frozen_string_literal: true
require_relative "../browser_test_helper"

class BrowserWorkflowsTest < BrowserTest
  test "Turbo saves a Partial choice and restores it after refresh" do
    visit "/"
    click_button "Present ChoiceCard"
    within ".rails-tool-views-surface" do
      choose "Compare options"
      click_button "Save selection"
      assert_text "Selection saved: compare."
      assert_text "Saved revision 2"
    end
    assert_equal 1, DemoEffect.uncached { DemoEffect.count }
    assert_selector "[data-rails-tool-views-revision-value='2']"
    page.refresh
    assert_checked_field "Compare options"
    assert_text "Selection saved: compare."
    assert_equal 1, DemoEffect.uncached { DemoEffect.count }
  end

  test "ViewComponent has the same interactive persistence contract" do
    visit "/"
    click_button "Render ViewComponent"
    choose "Continue analysis"
    click_button "Save selection"
    assert_text "Selection saved: continue."
    page.refresh
    assert_checked_field "Continue analysis"
    assert_equal 1, DemoEffect.uncached { DemoEffect.count }
  end

  test "customer validation retains values then creates once on a mobile page" do
    page.current_window.resize_to(390, 844)
    visit "/v1/customer"
    fill_in "Customer name", with: "Browser customer"
    fill_in "Customer email", with: "not-an-email"
    click_button "Create customer"
    assert_selector "[aria-invalid='true']"
    assert_field "Customer name", with: "Browser customer"
    assert_field "Customer email", with: "not-an-email"
    assert_equal 0, DemoCustomer.uncached { DemoCustomer.where(name: "Browser customer").count }
    take_screenshot("invalid-mobile")
    fill_in "Customer email", with: "browser@example.test"
    click_button "Create customer"
    assert_text "Created in north"
    page.refresh
    assert_text "Browser customer"
    assert_equal 1, DemoCustomer.uncached { DemoCustomer.where(name: "Browser customer").count }
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth"), "Mobile page overflows horizontally"
  end
end
