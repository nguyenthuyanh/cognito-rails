module Dashboard
  class DealsController < ApplicationController
    # skip_before_action :verify_authenticity_token
    protect_from_forgery with: :null_session

    def update
      crm = Crm::Hubspot.new

      # url = URI::HTTPS.build(host: "api.hubapi.com", path: "/files/v3/files")
      # f = File.open(Rails.root.join("app/assets/images/logo.svg").to_s)
      # options = {
      #   headers: {
      #     "Authorization" => " Bearer pat-eu1-de01ee7b-3fb2-4a86-9873-6ecf6de8fed4",
      #     "Content-type" => "multipart/form-data",
      #   },
      #   body: {
      #     file: f,
      #     folderPath: "/crm-properties-file-values",
      #     options: { "access": "PRIVATE" }.to_json,
      #   },
      # }

      # response = HTTParty.post(url, options)

      file = crm.client.files.files_api.upload(
        file: File.open(params[:file]),
        folder_path: "/crm-properties-file-values",
        options: { access: "PRIVATE" }.to_json,
        debug_return_type: "Hubspot::Files::File"
      )

      crm.client.crm.contacts.basic_api.update(contact_id: 32_038_733_775,
        body: { properties: { document_2: file.id } })
    end
  end
end
