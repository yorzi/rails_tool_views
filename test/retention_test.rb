# frozen_string_literal: true
require_relative "test_helper"

class RetentionTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def close_ready(**options)
    surface = present_card(**options)
    act(surface, idempotency: "saved")
    RailsToolViews.close(surface.id, scope: scope, retain_until: 1.hour.from_now)
  end

  def purge(**options)
    RailsToolViews.purge_closed(**{ scope: scope, closed_before: Time.current }.merge(options))
  end

  test "cleanup is denied by default and strict host policy authorizes each candidate" do
    close_ready
    travel 2.hours do
      assert_error("NOT_ALLOWED") { purge }
      RailsToolViews.configuration.retention_policy = ->(access) { access.operation == :purge && access.actor == "alice" && access.surface.closed? }
      assert_equal 1, purge[:eligible]
      RailsToolViews.configuration.retention_policy = ->(_) { "true" }
      assert_equal 1, purge[:protected]
      assert_nil RailsToolViews::Surface.first.purged_at
    end
  end

  test "preview does not write and apply scrubs payloads but preserves correlation and business data" do
    correlation = { adapter: "test", call_id: "old-call", context: "chat" }
    surface = close_ready(context: "private-context", correlation: correlation)
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    travel 2.hours do
      before = [surface.reload.attributes, RailsToolViews::ActionExecution.first.attributes, RailsToolViews::Presentation.first.attributes]
      assert_equal({ examined: 1, eligible: 1, purged: 0, protected: 0, dry_run: true, next_after: nil }, purge)
      assert_equal before, [surface.reload.attributes, RailsToolViews::ActionExecution.first.attributes, RailsToolViews::Presentation.first.attributes]
      assert_equal 1, purge(dry_run: false)[:purged]
      assert surface.reload.purged?
      assert_equal({}, surface.props)
      assert_equal({}, surface.state)
      assert_nil surface.context_ref
      assert_equal 0, RailsToolViews::ActionExecution.count
      assert_equal 1, RailsToolViews::Presentation.count
      assert_equal 1, DemoEffect.count
      assert_error("SURFACE_PURGED") { RailsToolViews.restore(surface.id, scope: scope) }
      assert_error("SURFACE_PURGED") { RailsToolViews.present(:choice_card, props: props, scope: scope, context: "private-context", correlation: correlation) }
      assert_error("SURFACE_PURGED") { act(surface, revision: 1, idempotency: "saved") }
      assert_error("NOT_FOUND") { RailsToolViews.restore(surface.id, scope: scope("other")) }
      assert_equal 1, RailsToolViews::Surface.count
      assert_equal 0, purge(dry_run: false)[:purged]
    end
  end

  test "scope cutoff deadline and batch limit exclude unrelated views" do
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    ready = 3.times.map { close_ready }
    present_card
    infinite = present_card
    RailsToolViews.close(infinite.id, scope: scope)
    foreign = close_ready
    foreign.update!(tenant_ref: "elsewhere")
    late = close_ready
    late.update!(retain_until: 10.days.from_now)
    travel 2.hours do
      assert_equal 0, purge(closed_before: 1.day.ago)[:examined]
      assert_equal 2, purge(batch_size: 2, dry_run: false)[:purged]
      assert_equal 1, purge(batch_size: 2, dry_run: false)[:purged]
      assert ready.all? { |s| s.reload.purged? }
      assert_not foreign.reload.purged?
      assert_not late.reload.purged?
      assert_not infinite.reload.purged?
    end
  end

  test "a cursor pages past protected views so newer eligible views are reached" do
    held = 2.times.map { close_ready }
    ready = 2.times.map { close_ready }
    RailsToolViews.configuration.retention_policy = ->(access) { held.none? { |surface| surface.id == access.surface.id } }
    travel 2.hours do
      # The oldest candidates are on hold; without a cursor every batch stops on them.
      2.times { assert_equal({ examined: 2, purged: 0, protected: 2 }, purge(batch_size: 2, dry_run: false).slice(:examined, :purged, :protected)) }
      first = purge(batch_size: 2, dry_run: false)
      assert_kind_of String, first[:next_after]
      second = purge(batch_size: 2, dry_run: false, after: first[:next_after])
      assert_equal({ examined: 2, purged: 2, protected: 0 }, second.slice(:examined, :purged, :protected))
      last = purge(batch_size: 2, dry_run: false, after: second[:next_after])
      assert_equal({ examined: 0, purged: 0, protected: 0, next_after: nil }, last.slice(:examined, :purged, :protected, :next_after))
      assert ready.all? { |surface| surface.reload.purged? }
      assert held.none? { |surface| surface.reload.purged? }
    end
  end

  test "a cursor orders ties by id, previews like apply and stays inside the scope" do
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    views = 3.times.map { close_ready }
    tied = Time.utc(2026, 10, 1, 12, 0, 0, 123_456)
    RailsToolViews::Surface.where(id: views.map(&:id)).update_all(closed_at: tied)
    travel 2.hours do
      seen, after = [], nil
      loop do
        summary = purge(batch_size: 1, after: after)
        seen << summary[:examined]
        after = summary[:next_after] or break
      end
      assert_equal [1, 1, 1, 0], seen
      assert_equal 0, RailsToolViews::Surface.where.not(purged_at: nil).count
      # A cursor from another scope's position only narrows this scope's query.
      assert_equal 3, purge(after: "2000-01-01T00:00:00.000000Z/#{SecureRandom.uuid}", dry_run: false)[:purged]
      assert_equal 0, purge(scope: scope("bob"), dry_run: false)[:examined]
    end
  end

  test "unfinished unknown and uncertain deliveries remain protected even if lifecycle was edited directly" do
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    RailsToolViews.configuration.auto_deliver = false
    register_card(:agent_card, agent: true)
    RailsToolViews.configuration.agent_adapter = ->(*) {}
    %w[pending failed delivering future_status completed].each do |status|
      surface = RailsToolViews.present(:agent_card, props: props, scope: scope)
      result = act(surface)
      RailsToolViews::AgentInteraction.find(result[:interaction_id]).update!(status: status, delivery_uncertain: status == "completed")
      surface.reload.update!(closed_at: 3.hours.ago, retain_until: 1.hour.ago)
    end
    assert_equal 5, purge(dry_run: false)[:protected]
    assert_equal 5, RailsToolViews::ActionExecution.count
  end

  test "abandoned receipt graphs are removed atomically and old delivery is unavailable" do
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    RailsToolViews.configuration.auto_deliver = false
    RailsToolViews.configuration.agent_adapter = ->(*) { flunk "abandoned callback" }
    register_card(:agent_card, agent: true)
    surface = RailsToolViews.present(:agent_card, props: props, scope: scope)
    result = act(surface)
    RailsToolViews.abandon(surface.id, scope: scope, retain_until: 1.hour.from_now)
    travel 2.hours do
      # An injected database failure after deleting a child must roll back all writes.
      surface_class = RailsToolViews::Surface
      surface_class.set_callback(:update, :before, :fail_purge_for_test)
      surface_class.define_method(:fail_purge_for_test) { raise "injected failure" if purged_at_changed? }
      begin
        assert_raises(RuntimeError) { purge(dry_run: false) }
      ensure
        surface_class.skip_callback(:update, :before, :fail_purge_for_test)
        surface_class.remove_method(:fail_purge_for_test)
      end
      assert_not surface.reload.purged?
      assert_equal 1, RailsToolViews::AgentInteraction.count
      assert_equal 1, RailsToolViews::ActionExecution.count
      assert_equal 1, purge(dry_run: false)[:purged]
      assert_equal 0, RailsToolViews::AgentInteraction.count
      assert_error("NOT_FOUND") { RailsToolViews.deliver(result[:interaction_id], scope: scope) }
      assert_equal 1, DemoEffect.count
    end
  end

  test "a candidate changed after selection is rechecked under the lock" do
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    surface = close_ready
    travel 2.hours do
      original = RailsToolViews::Surface.method(:find_by)
      RailsToolViews::Surface.stub(:find_by, ->(**query) {
        RailsToolViews::Surface.where(id: surface.id).update_all(tenant_ref: "other-tenant")
        original.call(**query)
      }) do
        assert_equal 1, purge(dry_run: false)[:protected]
      end
      assert_not surface.reload.purged?
      assert_equal 1, DemoEffect.count
    end
  end

  test "a request restored before cleanup cannot execute after the tombstone commits" do
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    surface = close_ready
    travel 2.hours do
      # Keep the same object identity/primary key but stale loaded payloads.
      stale = RailsToolViews::Surface.find(surface.id)
      assert_equal 1, purge(dry_run: false)[:purged]
      RailsToolViews.stub(:restore, stale) do
        assert_error("SURFACE_PURGED") { act(stale, revision: 1, idempotency: "saved") }
      end
      assert_equal 1, DemoEffect.count
    end
  end

  test "invalid cleanup parameters fail before mutations" do
    RailsToolViews.configuration.retention_policy = ->(_) { true }
    close_ready
    [{ batch_size: 0 }, { batch_size: 1001 }, { batch_size: "1" }, { dry_run: nil }, { dry_run: 0 }, { closed_before: "yesterday" }, { closed_before: 1.day.from_now },
      { after: 5 }, { after: "" }, { after: "garbage" }, { after: "2026-10-01T12:00:00Z/x" }, { after: "2026-13-01T12:00:00.000000Z/x" },
      { after: "2026-10-01T12:00:00.000000Z/" }, { after: "2026-10-01T12:00:00.000000Z/#{"x" * 300}" }].each do |args|
      assert_error("INVALID_RETENTION_REQUEST") { purge(**args) }
    end
    assert_nil RailsToolViews::Surface.first.purged_at
  end
end
