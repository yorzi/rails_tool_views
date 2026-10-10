# frozen_string_literal: true
class CreateV1DemoDomain < ActiveRecord::Migration[7.2]
  def change
    create_table :demo_staffs do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :tenant_ref, null: false
      t.string :name, null: false
      t.string :role, null: false
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    create_table :demo_customers do |t|
      t.string :tenant_ref, null: false
      t.string :name, null: false
      t.string :email, null: false
      t.timestamps
    end
    add_index :demo_customers, [:tenant_ref, :email], unique: true
    create_table :demo_tickets do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :tenant_ref, null: false
      t.references :customer, null: false, foreign_key: { to_table: :demo_customers }
      t.references :assignee, foreign_key: { to_table: :demo_staffs }
      t.string :subject, null: false
      t.string :status, null: false, default: "open"
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
    create_table :demo_replies do |t|
      t.references :ticket, null: false, foreign_key: { to_table: :demo_tickets }, index: { unique: true }
      t.text :body, null: false
      t.string :status, null: false, default: "draft"
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
    create_table :demo_outbound_replies do |t|
      t.references :reply, null: false, foreign_key: { to_table: :demo_replies }
      t.integer :reply_version, null: false
      t.text :body, null: false
      t.string :status, null: false, default: "queued_locally"
      t.timestamps
    end
    add_index :demo_outbound_replies, [:reply_id, :reply_version], unique: true
    create_table :demo_artifacts do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :tenant_ref, null: false
      t.string :title, null: false
      t.integer :current_version, null: false, default: 1
      t.integer :accepted_version
      t.integer :lock_version, null: false, default: 0
      t.timestamps
    end
    create_table :demo_artifact_versions do |t|
      t.references :artifact, null: false, foreign_key: { to_table: :demo_artifacts }
      t.integer :number, null: false
      t.text :body, null: false
      t.string :origin, null: false
      t.timestamps
    end
    add_index :demo_artifact_versions, [:artifact_id, :number], unique: true
    create_table :demo_exports do |t|
      t.references :artifact, null: false, foreign_key: { to_table: :demo_artifacts }
      t.integer :artifact_version, null: false
      t.text :body, null: false
      t.timestamps
    end
    add_index :demo_exports, [:artifact_id, :artifact_version], unique: true
    create_table :demo_agent_receipts do |t|
      t.string :delivery_key, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
