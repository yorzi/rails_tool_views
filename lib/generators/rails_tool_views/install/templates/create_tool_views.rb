# frozen_string_literal: true
class CreateToolViews < ActiveRecord::Migration[7.2]
  def change
    create_table :tool_views_surfaces, id: :string do |t|
      t.string :actor_ref, null: false
      t.string :tenant_ref, null: false
      t.string :context_ref
      t.string :component_key, null: false
      t.string :component_digest, null: false
      t.integer :contract_version, default: 1, null: false
      t.json :props, null: false
      t.json :state, null: false
      t.integer :revision, default: 1, null: false
      t.integer :lock_version, default: 0, null: false
      t.timestamps
    end
    add_index :tool_views_surfaces, [:tenant_ref, :actor_ref]
    create_table :tool_views_presentations do |t|
      t.references :surface, type: :string, foreign_key: { to_table: :tool_views_surfaces }, null: false
      t.string :actor_ref, null: false
      t.string :tenant_ref, null: false
      t.string :adapter, null: false
      t.string :call_id, null: false
      t.string :context_ref, null: false
      t.string :request_digest, null: false
      t.json :result, null: false
      t.timestamps
    end
    add_index :tool_views_presentations, [:tenant_ref, :actor_ref, :adapter, :call_id, :context_ref], unique: true, name: "index_tool_views_call_scope"
    create_table :tool_views_action_executions do |t|
      t.references :surface, type: :string, foreign_key: { to_table: :tool_views_surfaces }, null: false
      t.string :actor_ref, null: false
      t.string :action_key, null: false
      t.string :idempotency_key, null: false
      t.string :request_digest, null: false
      t.integer :base_revision, null: false
      t.json :result, null: false
      t.timestamps
    end
    add_index :tool_views_action_executions, [:surface_id, :idempotency_key], unique: true, name: "index_tool_views_action_replay"
    create_table :tool_views_agent_interactions do |t|
      t.references :surface, type: :string, foreign_key: { to_table: :tool_views_surfaces }, null: false
      t.references :action_execution, foreign_key: { to_table: :tool_views_action_executions }, null: false, index: { unique: true }
      t.json :payload, null: false
      t.string :status, null: false, default: "pending"
      t.string :error_code
      t.datetime :claimed_at
      t.integer :attempts, null: false, default: 0
      t.timestamps
    end
  end
end
