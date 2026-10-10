# frozen_string_literal: true
module DemoV1
  module Exports
    module_function
    def render(version)
      version.body
    end
    def call(artifact)
      DemoExport.find_or_create_by!(artifact: artifact, artifact_version: artifact.accepted_version) do |export|
        export.body = render(artifact.current)
      end
    end
  end
end
