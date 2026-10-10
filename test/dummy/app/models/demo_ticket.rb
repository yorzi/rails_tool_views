# frozen_string_literal: true
class DemoTicket < ActiveRecord::Base
  belongs_to :customer, class_name: "DemoCustomer"
  belongs_to :assignee, class_name: "DemoStaff", optional: true
  has_one :reply, class_name: "DemoReply", foreign_key: :ticket_id
end
