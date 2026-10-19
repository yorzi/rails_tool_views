# frozen_string_literal: true
class AddRailsToolViewsLifecycle < ActiveRecord::Migration[7.2]
  def up
    add_column :rails_tool_views_surfaces, :closed_at, :datetime
    add_column :rails_tool_views_surfaces, :abandoned_at, :datetime
    add_column :rails_tool_views_surfaces, :retain_until, :datetime
    add_column :rails_tool_views_surfaces, :purged_at, :datetime
    add_index :rails_tool_views_surfaces, [:tenant_ref, :actor_ref, :closed_at], name: "index_rails_tool_views_retention_scope"
    add_column :rails_tool_views_agent_interactions, :delivery_uncertain, :boolean, default: false, null: false
    # Old rows do not distinguish explicit failed retries from lease takeovers.
    # Preserve uncertainty instead of assuming an old callback has stopped.
    execute "UPDATE rails_tool_views_agent_interactions SET delivery_uncertain = #{connection.quote(true)} WHERE attempts > 1 OR status = 'delivering'"
  end

  def down
    if select_value("SELECT COUNT(*) FROM rails_tool_views_surfaces WHERE closed_at IS NOT NULL").to_i.positive?
      raise ActiveRecord::IrreversibleMigration, "Closed or purged Surfaces cannot be safely reopened by an older runtime. Restore a pre-upgrade backup instead."
    end
    remove_column :rails_tool_views_agent_interactions, :delivery_uncertain
    remove_index :rails_tool_views_surfaces, name: "index_rails_tool_views_retention_scope"
    %i[closed_at abandoned_at retain_until purged_at].each { |column| remove_column :rails_tool_views_surfaces, column }
  end
end
