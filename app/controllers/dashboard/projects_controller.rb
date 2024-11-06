module Dashboard
  class ProjectsController < ApplicationController
    def index
      contact = hubspot.get_contact(id: current_user.hs_contact_id, associations: :deal)
      deals = contact.deal_ids.map { |id| hubspot.get_deal(id:) }

      render locals: { deals: }
    end

    def show
      contact = hubspot.get_contact_files(id: current_user.hs_contact_id, attributes: [:file1, :file2])
      deal = hubspot.get_deal_files(id: params[:id])

      quote_ids = hubspot.get_deal(id: params[:id], associations: :quote).quote_ids || []
      quotes = quote_ids.map { |id| hubspot.get_quote(id:, attributes: [:reference, :download_url]) }

      invoices = Crm::Pennylane.new.get_invoices_by_client_id(current_user.pl_client_id)

      render locals: { contact:, deal:, quotes:, invoices: }
    end

    def update
      result = Crm::HubspotServices::UploadDocuments.call(params: project_params)

      redirect_to dashboard_project_path(id: params[:id]) if result.success?
    end

    private
      def project_params
        params.require(:project).permit(:deal_id, :impot_file, :mairie_file, :contract_file).merge(deal_id: params[:id])
      end

      def hubspot
        @hubspot ||= Crm::Hubspot.new
      end
  end
end
