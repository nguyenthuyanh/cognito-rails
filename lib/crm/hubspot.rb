# frozen_string_literal: true

module Crm
  class MappingError < StandardError; end

  class Hubspot
    attr_reader :client

    ATTR_MAPPING = YAML.load_file(File.join(__dir__, "mapping.yml")).deep_symbolize_keys

    def initialize
      @client = ::Hubspot::Client.new(access_token: ENV["HUBSPOT_API_KEY"])
    end

    ATTR_MAPPING.each_key do |object_name|
      # Get object data by object id
      define_method("get_#{object_name}") do |id:, associations: nil, properties: nil|
        client.crm.send(object_name.to_s.pluralize).basic_api.get_by_id("#{object_name}_id": id, associations:,
          properties:)
      end

      # Get files download url, get all files by default
      define_method("get_#{object_name}_files") do |id:, file_attrs: nil|
        file_mapping = ATTR_MAPPING[object_name.to_sym][:files]
        file_attrs ||= file_mapping.keys

        properties = file_attrs.map do |attr|
          raise MappingError, "No attribute matches '#{attr}'" unless file_mapping.key?(attr)

          file_mapping[attr]
        end

        files = send("get_#{object_name}", id:, properties:).properties

        file_attrs.each_with_object({}) do |attr, hash|
          propertie_name = file_mapping[attr]

          next if files[propertie_name].blank?

          file_ids = files[propertie_name].split(";")
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
