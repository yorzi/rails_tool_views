# frozen_string_literal: true
class DemoReply < ActiveRecord::Base
  belongs_to :ticket, class_name: "DemoTicket"
  validates :body, presence: true, length: { maximum: 2000 }
end
