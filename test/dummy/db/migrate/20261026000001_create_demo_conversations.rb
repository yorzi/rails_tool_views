# frozen_string_literal: true
# A minimal transcript for the agent demo. Production hosts usually persist
# chats with RubyLLM's acts_as_chat; this keeps the demo free of its schema.
class CreateDemoConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :demo_conversations do |t|
      t.string :actor_ref, null: false
      t.string :tenant_ref, null: false
      t.timestamps
    end
    add_index :demo_conversations, [:tenant_ref, :actor_ref]
    create_table :demo_chat_messages do |t|
      t.references :conversation, null: false, foreign_key: { to_table: :demo_conversations }
      t.string :role, null: false
      t.text :content
      t.json :tool_calls
      t.string :tool_call_id
      t.timestamps
    end
  end
end
