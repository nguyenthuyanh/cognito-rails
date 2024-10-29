# frozen_string_literal: true

module Crm
  class MappingError < StandardError; end

  class Hubspot
    attr_reader :client

    ATTR_MAPPING = YAML.load_file(File.join(__dir__, "mapping.yml")).deep_symbolize_keys
    DEFAULT_FOLDER_PATH = "/crm-properties-file-values"

    def initialize
      @client = ::Hubspot::Client.new(access_token: ENV["HUBSPOT_API_KEY"])
    end

    ATTR_MAPPING.each_key do |object_name| # rubocop:disable Metrics/BlockLength
      # Get object data by object id
      define_method("get_#{object_name}") do |id:, associations: nil, attributes: nil|
        object_mapping = ATTR_MAPPING[object_name.to_sym]

        result = client.crm.send(object_name.to_s.pluralize).basic_api.get_by_id(
          "#{object_name}_id": id,
          associations:,
          properties: get_mapping_properties(object_mapping, attributes)
        )

        args = build_mapping_object(result, object_mapping)

        "crm/models/#{object_name}".camelize.constantize.new(args)
      end

      define_method("update_#{object_name}") do |id:, attributes:|
        client.crm.send(object_name.to_s.pluralize).basic_api.update(
          "#{object_name}_id": id,
          body: { properties: get_mapping_params(ATTR_MAPPING[object_name.to_sym], attributes) }
        )
      end

      # Get files download url, get all files by default
      define_method("get_#{object_name}_files") do |id:, file_attrs: nil|
        file_attrs ||= ATTR_MAPPING[object_name.to_sym][:files].keys

        object = send("get_#{object_name}", id:, attributes: file_attrs)

        file_attrs.each do |attr|
          next if object.send(attr).blank?

          file_urls = object.send(attr).map { |file_id| get_file_url(file_id) }

          object.send("#{attr}=", file_urls)
        end

        object
      end

      define_method("upload_#{object_name}_file") do |id, attribute, file|
        file_name = file.original_filename if file.is_a?(ActionDispatch::Http::UploadedFile)
        file = upload_file(file, file_name)

        send("update_#{object_name}", id:, attributes: { attribute => file.id })
      end
    end

    def get_quotes_from_contact_id(contact_id)
      deal_ids = get_contact(id: contact_id, associations: :deal).deal_ids

      quote_ids = deal_ids.map { |deal_id| get_deal(id: deal_id, associations: :quote).quote_ids }.compact
      quote_ids.map { |id| get_quote(id:, attributes: [:reference, :download_url]) }
    end

    private
      def get_mapping_properties(object_mapping, attributes)
        properties_mapping = object_mapping.slice(:properties, :files).values.reduce({}, :merge)
        attributes&.map do |attr|
          raise MappingError, "No attribute matches '#{attr}'" unless properties_mapping.key?(attr)

          properties_mapping[attr]
        end
      end

      def get_mapping_params(object_mapping, attributes)
        properties_mapping = object_mapping.slice(:properties, :files).values.reduce({}, :merge)

        attributes&.each_with_object({}) do |attribute, hash|
          attr_name, attr_value = attribute
          raise MappingError, "No attribute matches '#{attr_name}'" unless properties_mapping.key?(attr_name)

          hash[properties_mapping[attr_name]] = attr_value
        end
      end

      def build_mapping_object(res, mapping)
        object_hash = {}

        object_hash.merge!(build_mapping_associations(res, mapping[:associations])) if mapping[:associations].present?
        object_hash.merge!(build_mapping_properties(res, mapping[:properties])) if mapping[:properties].present?
        object_hash.merge!(build_mapping_files(res, mapping[:files])) if mapping[:files].present?

        object_hash.compact.deep_symbolize_keys
      end

      def build_mapping_associations(res, attr_mapping)
        attr_mapping.each_with_object({}) do |association, hash|
          if (object = res&.associations&.[](association.to_s.pluralize)).present?
            hash["#{association}_ids"] = object.results.map(&:id)
          end
        end
      end

      def build_mapping_properties(res, attr_mapping)
        attr_mapping.each_with_object({}) do |object, hash|
          attr_name, prop_name = object
          hash[attr_name] = res.properties[prop_name]
        end
      end

      def build_mapping_files(res, attr_mapping)
        attr_mapping.each_with_object({}) do |object, hash|
          attr_name, prop_name = object
          hash[attr_name] = res.properties[prop_name]&.split(";")
        end
      end

      def get_file_url(id)
        client.files.files_api.get_signed_url(file_id: id)
      end

      def upload_file(file, file_name=nil)
        opts = {
          file: File.open(file),
          file_name: file_name,
          folder_path: DEFAULT_FOLDER_PATH,
          options: { access: "PRIVATE" }.to_json,
          debug_return_type: "Hubspot::Files::File",
        }.compact

        client.files.files_api.upload(opts)
      end
  end
end
