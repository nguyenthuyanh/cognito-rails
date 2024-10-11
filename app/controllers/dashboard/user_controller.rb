module Dashboard
  class UserController < ApplicationController
    def index
      user = Crm::Hubspot.new

      @document = user.document
    end
  end
end
