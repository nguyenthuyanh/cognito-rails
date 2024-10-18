module Dashboard
  class ProjectsController < ApplicationController
    protect_from_forgery with: :null_session, only: [:update]

    def index
      # TODO: adapt to several deals
      deal_id = Crm::Hubspot.new.get_contact(
        id: current_user[:"custom:hubspot_contact_id"],
        associations: :deal
      ).associations["deals"].results.first.id

      render locals: { deal_id: }
    end

    def update
      # TODO: handle error and move to service object
      crm = Crm::Hubspot.new
      crm.upload_deal_file(params[:id], :impot_file, project_params[:impot_file])
      crm.upload_deal_file(params[:id], :mairie_file, project_params[:mairie_file])
      crm.upload_deal_file(params[:id], :contract_file, project_params[:contract_file])

      redirect_to dashboard_profile_path
    end

    private
      def project_params
        params.require(:project).permit(:impot_file, :mairie_file, :contract_file)
      end
  end
end
