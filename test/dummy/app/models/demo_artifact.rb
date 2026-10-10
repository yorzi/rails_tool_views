# frozen_string_literal: true
class DemoArtifact < ActiveRecord::Base
  has_many :versions, class_name: "DemoArtifactVersion", foreign_key: :artifact_id
  def current
    versions.find_by!(number: current_version)
  end
end
