module Crm
  module HubspotServices
    class UploadDocuments < BaseService
      def call
        hubspot.upload_deal_file(params[:deal_id], :impot_file, params[:impot_file])
        hubspot.upload_deal_file(params[:deal_id], :mairie_file, params[:mairie_file])
        hubspot.upload_deal_file(params[:deal_id], :contract_file, params[:contract_file])
      end
    end
  end
end
