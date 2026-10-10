# frozen_string_literal: true
class DemoCustomer < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 120 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 200 }, uniqueness: { scope: :tenant_ref }
end
