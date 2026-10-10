# frozen_string_literal: true
class DemoOutboundReply < ActiveRecord::Base
  belongs_to :reply, class_name: "DemoReply"
end
