# frozen_string_literal: true

module Crm
  class Hubspot
    attr_reader :client, :user_id

    def initialize(user_id: nil)
      @client = ::Hubspot::Client.new(access_token: ENV["HUBSPOT_API_KEY"])
      @user_id = user_id || 32_038_733_775
    end

    def contact
      client.crm.contacts.basic_api.get_by_id(contact_id: user_id, associations: :deal)
    end

    def deal
      client.crm.deals.basic_api.get_by_id(
        deal_id: contact.associations["deals"].results.first.id,
        properties: [:documentfiletest]
      )
    end

    def document
      client.files.files_api.get_signed_url(file_id: deal.properties["documentfiletest"])
    end
  end
end
