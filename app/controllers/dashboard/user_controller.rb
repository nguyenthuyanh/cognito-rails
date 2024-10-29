module Dashboard
  class UserController < ApplicationController
    def index
      # TODO: update with real data
      hubspot = Crm::Hubspot.new
      contact = hubspot.get_contact_files(id: current_user.hs_contact_id, file_attrs: [:file1, :file2])
      deal_id = hubspot.get_contact(id: current_user.hs_contact_id, associations: :deal).deal_ids.first
      deal = hubspot.get_deal_files(id: deal_id)

      quote_ids = hubspot.get_deal(id: deal_id, associations: :quote).quote_ids
      quotes = quote_ids.map { |id| hubspot.get_quote(id:, attributes: [:reference, :download_url]) }

      pennylane = Crm::Pennylane.new
      pl_client = pennylane.get_client_by_reference(quotes.first.reference)
      invoices = pennylane.get_invoices_by_client_id(pl_client[:source_id])

      render locals: { contact:, deal:, quotes:, invoices: }
    end
  end
end
