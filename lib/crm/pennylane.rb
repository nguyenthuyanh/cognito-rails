module Crm
  class ApiResponseError < StandardError; end
  class PennylaneError < StandardError; end

  class Pennylane
    class << self
      attr_accessor :api_token, :host, :api_path

      def setup
        yield self
      end

      def headers
        {
          Authorization: "Bearer #{api_token}",
          accept: "application/json",
        }
      end

      def api_request(method: :post, endpoint: nil, queries: {}, body: nil)
        url = get_url(endpoint, queries)

        begin
          response = HTTParty.send(method, url, headers:, body:)
        rescue StandardError => e
          response = e.response

          message = "Method: #{method}, Url: #{url}, Payload: #{payload}, Response: #{response}"
          Rails.logger.debug ApiResponseError.new(message)
        end

        response.deep_symbolize_keys
      end

      private
        def get_url(endpoint, queries)
          URI::HTTPS.build(
            host:,
            path: "/#{api_path}/#{endpoint}",
            query: queries.to_query
          ).to_s
        end
    end

    def get_client_by_reference(reference)
      filters = [{ field: "reference", operator: "eq", value: reference }].to_json
      response = self.class.api_request(
        method: :get,
        endpoint: "customers",
        queries: { filter: filters }
      )

      return response[:customers].first if response[:total_customers] == 1

      raise PennylaneError, "Found #{response[:total_customers].to_i} customers with same reference"
    end

    def get_invoices_by_client_id(id)
      filters = [{ field: "customer_id", operator: "eq", value: id }].to_json
      self.class.api_request(
        method: :get,
        endpoint: "customer_invoices",
        queries: { filter: filters }
      )[:invoices]
    end
  end
end
