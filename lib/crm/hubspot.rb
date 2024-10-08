# frozen_string_literal: true

module Crm
  class Hubspot
    attr_reader :client

    def initialize(user_id:)
      @client = ::Hubspot::Client.new(access_token: ENV["HUBSPOT_API_KEY"])
      @contact_id = user_id
    end

    def get_contact(id:)
      client.crm.contacts.basic_api.get_by_id(contact_id: id)
    end

    def document
      deal = client.crm.deals.basic_api.get_by_id(deal_id: 16_462_742_719, properties: [:documentfiletest])

      client.files.files_api.get_signed_url(file_id: deal.properties["documentfiletest"])
    end
  end
end
