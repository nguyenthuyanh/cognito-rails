class IndexController < ApplicationController
  skip_before_action :restrict_access, only: [:index]

  def index; end

  def user
    user = Crm::Hubspot.new(user_id: current_user[:sub])

    @document = user.document
  end
end
