# frozen_string_literal: true
require_relative 'test_helper'
require 'stringio'
class V1PrivacyTest < ActiveSupport::TestCase
  setup do
    DemoV1::Seeds.call
    DemoV1::Registration.call
  end
  test 'host body fields and core submitted values do not leak into SQL or notifications' do
    events = []
    token = ActiveSupport::Notifications.subscribe(/\.tool_views\z/) { |*args| events << args.last }
    stream = StringIO.new
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = ActiveSupport::Logger.new(stream)
    scope = DemoV1::Access.scope_for(DemoStaff.find_by!(code: 'north-lead'))
    artifact = DemoArtifact.find_by!(code: 'north-artifact')
    surface = RailsToolViews.present(:result_review, props: { artifact_id: artifact.id.to_s }, scope: scope)
    RailsToolViews.dispatch(surface.id, scope: scope, action: 'edit', arguments: { body: 'private-domain-sentinel', artifact_version: '1' }, base_revision: 1, idempotency_key: 'private-edit')
    refute_includes stream.string, 'private-domain-sentinel'
    refute_includes JSON.generate(events), 'private-domain-sentinel'
    assert_equal({ 'artifact_id' => artifact.id.to_s }, surface.props)
  ensure
    ActiveRecord::Base.logger = old_logger
    ActiveSupport::Notifications.unsubscribe(token) if token
  end
  test 'accepted host artifact body remains escaped in the real renderer' do
    scope = DemoV1::Access.scope_for(DemoStaff.find_by!(code: 'north-lead'))
    artifact = DemoArtifact.find_by!(code: 'north-artifact')
    surface = RailsToolViews.present(:result_review, props: { artifact_id: artifact.id.to_s }, scope: scope)
    RailsToolViews.dispatch(surface.id, scope: scope, action: 'edit', arguments: { body: '<script>attack()</script>', artifact_version: '1' }, base_revision: 1, idempotency_key: 'escaped')
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    controller.response = ActionDispatch::TestResponse.new
    html = RailsToolViews.render(surface, view_context: controller.view_context, scope: scope)
    assert_includes html, '&lt;script&gt;attack()&lt;/script&gt;'
    refute_includes html, '<script>attack()</script>'
  end
end
