module Dashboard
  class UserController < ApplicationController
    def index
      crm = Crm::Hubspot.new(user_id: 32_038_733_775)
      contact = crm.get_contact(contact_id: 32_038_733_775, associations: :deal)
      documents = crm.get_deal_files(id: contact.associations["deals"].results.first.id)

      render locals: { documents: }
    end
  end
end
