# frozen_string_literal: true
class DemoExport < ActiveRecord::Base
  belongs_to :artifact, class_name: "DemoArtifact"
end
