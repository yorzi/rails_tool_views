# frozen_string_literal: true
class DemoArtifactVersion < ActiveRecord::Base
  belongs_to :artifact, class_name: "DemoArtifact"
  validates :body, presence: true, length: { maximum: 4000 }
  def readonly?
    persisted?
  end
end
