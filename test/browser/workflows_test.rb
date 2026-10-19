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
    mobile_viewport
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
  test "without JavaScript a complete mobile error page supports correction and refresh" do
    with_browser(:rails_tool_views_no_js) do
      mobile_viewport
      visit "/v1/customer"
      fill_in "Customer name", with: "HTML customer"
      fill_in "Customer email", with: "invalid"
      click_button "Create customer"
      assert_title "Unable to complete this request"
      assert_selector "main h1", text: "Unable to complete this request"
      assert_field "Customer name", with: "HTML customer"
      assert_field "Customer email", with: "invalid"
      assert_selector "[aria-invalid=true][aria-describedby]"
      assert_equal 0, DemoCustomer.uncached { DemoCustomer.where(name: "HTML customer").count }
      take_screenshot("no-js-invalid-mobile")
      fill_in "Customer email", with: "html@example.test"
      click_button "Create customer"
      assert_title "Interactive view"
      assert_text "Created in north"
      page.refresh
      assert_text "HTML customer"
      assert_equal 1, DemoCustomer.uncached { DemoCustomer.where(name: "HTML customer").count }
      take_screenshot("no-js-corrected-mobile")
    end
  end

  test "closed views stay read-only and payload cleanup preserves the business action" do
    with_browser(:rails_tool_views_no_js) do
      visit "/"
      click_button "Present ChoiceCard"
      choose "Compare options"
      click_button "Save selection"
      assert_text "Selection saved: compare."
      click_button "Close view"
      assert_text "View closed."
      assert_no_button "Save selection"
      click_button "Preview cleanup"
      assert_text "Cleanup: 0 eligible, 0 purged."
      # Advance the fixture's clock; production deadlines are never bypassed.
      travel_to 2.days.from_now do
        click_button "Preview cleanup"
        assert_text "Cleanup: 1 eligible, 0 purged."
        assert_equal 1, RailsToolViews::ActionExecution.uncached { RailsToolViews::ActionExecution.count }
        take_screenshot("closed-preview")
        click_button "Clean eligible views"
        assert_text "Cleanup: 1 eligible, 1 purged."
        assert_text "1 cleaned views"
        assert_text "Selection saved"
        assert_equal 1, DemoEffect.uncached { DemoEffect.count }
        assert_equal 0, RailsToolViews::ActionExecution.uncached { RailsToolViews::ActionExecution.count }
        page.refresh
        assert_no_selector ".rails-tool-views-surface"
        take_screenshot("cleaned-business-log")
      end
    end
  end

end
