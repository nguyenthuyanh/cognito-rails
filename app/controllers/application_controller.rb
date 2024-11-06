class ApplicationController < ActionController::Base
  include PognitoConcern

  def index
    redirect_to dashboard_root_path if pognito.tokens?
  end
end
