module Dashboard
  class UserController < ApplicationController
    def index
      # TODO: update with real data
      contact_id = 32_038_733_775
      crm = Crm::Hubspot.new
      contact_files = crm.get_contact_files(id: contact_id, file_attrs: [:file1])
      contact = crm.get_contact(id: contact_id, associations: :deal)
      deal_files = crm.get_deal_files(id: contact.associations["deals"].results.first.id)

      render locals: { contact_files:, deal_files: }
    end
  end
end
