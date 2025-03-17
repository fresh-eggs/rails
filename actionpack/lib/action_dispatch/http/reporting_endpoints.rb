# frozen_string_literal: true

module ActionDispatch
  class ReportingEndpoints
    attr_accessor :endpoints

    class NonTrustworthyURLError < StandardError
    end

    def initialize
      @endpoints = {}
      yield self if block_given?
    end

    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, _ = response = @app.call(env)

        return response if header_present?(headers)
        request = ActionDispatch::Request.new env

        unless request.reporting_endpoints.nil?
          headers[ActionDispatch::Constants::REPORTING_ENDPOINTS] =
            request.reporting_endpoints.build
        end
        response
      end

      private

      def header_present?(headers)
        !headers[ActionDispatch::Constants::REPORTING_ENDPOINTS].nil?
      end
    end

    module Request
      def reporting_endpoints
        get_header("action_dispatch.reporting_endpoints")
      end

      def reporting_endpoints=(value)
        set_header("action_dispatch.reporting_endpoints", value)
      end
    end

    def build
      reporting_endpoints = @endpoints.map do |endpoint_name, url|
        validate_endpoint(url)
        "#{endpoint_name}=\"#{url}\""
      end

      reporting_endpoints.join(', ')
    end

    def validate_endpoint(url)
      # https://w3c.github.io/webappsec-secure-contexts/#is-origin-trustworthy
      msg =  <<-ERROR
        http schemes are not considered Potentially Trustworhty origins
        and may be ignored as Reporting Endpoints: #{url}"
      ERROR

      endpoint = URI.parse(url)
      raise NonTrustworthyURLError.new(msg) if endpoint.scheme == "http"
    rescue URI::InvalidURIError
      raise ArgumentError, "Invalid endpoint value provided to Reporting Endpoints."
    end
  end
end
