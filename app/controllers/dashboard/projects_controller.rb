module Dashboard
  class ProjectsController < ApplicationController
    def index
      # TODO: adapt to several deals
      deal_id = Crm::Hubspot.new.get_contact(
        id: current_user.hs_contact_id,
        associations: :deal
      ).deal_ids.first

      render locals: { deal_id: }
    end

    def update
      result = Crm::HubspotServices::UploadDocuments.call(params: project_params)

      redirect_to dashboard_profile_path if result.success?
    end

    private
      def project_params
        params.require(:project).permit(:deal_id, :impot_file, :mairie_file, :contract_file).merge(deal_id: params[:id])
      end
  end
end
