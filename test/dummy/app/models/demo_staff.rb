# frozen_string_literal: true
class DemoStaff < ActiveRecord::Base
  self.table_name = "demo_staffs"
  # Rails 7.2 does not infer SQLite's newer DEFAULT TRUE schema expression.
  attribute :active, :boolean, default: true
  validates :role, inclusion: { in: %w[lead agent] }
  def actor_ref
    "staff:#{id}"
  end
end
