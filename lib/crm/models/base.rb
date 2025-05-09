module Crm
  module Models
    class AttributeMissingError < StandardError; end

    class Base
      attr_accessor :id, :files
      attr_reader :client_api

      def initialize(attributes)
        attr_mapping = Hubspot::ATTR_MAPPING[model_name]
        @attributes = attr_mapping.slice(:properties, :files).values.reduce({}, :merge).keys

        if attr_mapping[:associations].present?
          association_attr = attr_mapping[:associations].map { |attr| "#{attr}_ids".to_sym }
          @attributes.push(*association_attr)
        end

        @attributes.each do |attr_name|
          self.class.class_eval { attr_accessor attr_name }
        end

        attributes.each do |attribute_name, attribute_value|
          self.instance_variable_set("@#{attribute_name}", attribute_value)
        end

        @client_api = Hubspot.new
      end

      private
        def model_name
          @model_name ||= self.class.to_s.demodulize.underscore.to_sym
        end

        def build_object_from_response(res)
          res.each { |k, v| send("#{k}=", v) }

          self
        end
    end
  end
end
