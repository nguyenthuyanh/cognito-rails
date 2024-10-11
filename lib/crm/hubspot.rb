# frozen_string_literal: true

module Crm
  class Hubspot
    attr_reader :client, :user_id

    OBJECTS = [:contact, :deal].freeze

    CONTACT_FILES = []

    FILES_MAP = {
      contact: {
        first_document: :document_2,
        second_document: :contact_document,
      },
      deal: {
        document_test: :documentfiletest,
        mairie_document: :mairie_document,
        contract_document: :contract_document,
      },
    }

    def initialize(user_id: nil)
      @client = ::Hubspot::Client.new(access_token: ENV["HUBSPOT_API_KEY"])
      @user_id = user_id
    end

    OBJECTS.each do |object_name|
      define_method("get_#{object_name}") do |args|
        client.crm.send(object_name.to_s.pluralize).basic_api.get_by_id(args)
      end

      define_method("get_#{object_name}_files") do |id:, file_attrs: nil|
        file_attrs ||= FILES_MAP[object_name.to_sym].values
        files = send("get_#{object_name}", "#{object_name}_id": id, properties: file_attrs).properties.symbolize_keys

        file_attrs.each_with_object({}) do |attr, hash|
          next if files[attr].blank?

          file_ids = files[attr].split(";")
          file_urls = file_ids.map { |file_id| get_file_url(file_id) }

          hash[attr] = file_urls
        end
      end
    end

    private
      def get_file_url(id)
        client.files.files_api.get_signed_url(file_id: id)
      end
  end
end
