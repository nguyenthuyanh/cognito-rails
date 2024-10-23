module Dashboard
  class UserController < ApplicationController
    def index
      # TODO: update with real data
      contact_id = 32_038_733_775
      crm = Crm::Hubspot.new
      contact = crm.get_contact_files(id: contact_id, file_attrs: [:file1, :file2])
      deal_id = crm.get_contact(id: contact_id, associations: :deal).deal_ids.first
      deal = crm.get_deal_files(id: deal_id)

      quote_ids = crm.get_deal(id: deal_id, associations: :quote).quote_ids
      quotes = quote_ids.map { |id| crm.get_quote(id:, attributes: [:reference]) }

      render locals: { contact:, deal:, quotes: }
    end
  end
end
