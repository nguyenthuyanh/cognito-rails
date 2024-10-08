class IndexController < ApplicationController
  skip_before_action :restrict_access, only: [:index]

  def index; end

  def user
    user = Crm::Hubspot.new

    @document = user.document
  end
end
