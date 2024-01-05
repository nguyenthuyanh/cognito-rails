class IndexController < ApplicationController
  include PognitoConcern

  before_action :restrict_access, only: [:user]

  def index
    render locals: { current_user: }
  end

  def user
    render locals: { current_user: }
  end
end
