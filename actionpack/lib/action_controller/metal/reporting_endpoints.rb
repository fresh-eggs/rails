# frozen_string_literal: true

module ActionController
  module ReportingEndpoints
    extend ActiveSupport::Concern

    include AbstractController::Helpers
    include AbstractController::Callbacks

    module ClassMethods
      def reporting_endpoints(enabled = true, **options, &block)
        before_action(options) do
          current_endpoints = request.reporting_endpoints

          if block_given?
            instance_exec(current_endpoints, &block)
            request.reporting_endpoints = current_endpoints
          end

          request.reporting_endpoints = nil unless enabled
        end
      end
    end
  end
end
