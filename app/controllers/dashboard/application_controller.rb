module Dashboard
  class ApplicationController < ApplicationController
    before_action :authenticate_user

    def index
      render template: "dashboard/index"
    end

    private
      def render(options={}, extra_options={}, &block)
        options[:locals] ||= {}
        options[:locals][:current_user] = current_user

        super
      end
  end
end
