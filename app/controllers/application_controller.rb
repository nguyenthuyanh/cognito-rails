class ApplicationController < ActionController::Base
  include PognitoConcern

  before_action :restrict_access

  private
    def render(options={ locals: {} }, extra_options={}, &block)
      options[:locals][:current_user] = current_user

      super
    end
end
