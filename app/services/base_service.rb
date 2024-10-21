# frozen_string_literal: true

# Base service.
# If object is not provided, it will be initialized with the object class from the singularized parent if possible.
# If object is provided, it will be used as is.
# Additional getter (public) and setter (private) for object will be automatically set as the singularized and underscored parent of the class if present
class BaseService
  class << self
    def call(object: nil, params: {})
      define_object_methods

      instance = new(object, params)

      instance.call

      instance
    end

    def object_class_name_from_parent
      parent_name = module_parent.name

      @object_class_name_from_parent ||= if parent_name.include?("Services")
        parent_name.gsub("Services", "")
      else
        parent_name.singularize
      end
    end

    private
      def define_object_methods
        object_name = object_class_name_from_parent.demodulize.underscore

        define_method(object_name, -> { @object })

        setter = "#{object_name}="

        define_method(setter, -> (v) { @object = v })
        send(:private, setter)
      end
  end

  attr_reader :object, :params, :errors

  def initialize(object, params)
    @errors = []
    @params = params

    @object = object || (object_class_from_parent.new if object_class_from_parent.respond_to?(:new))
  end

  def success?
    @errors.none?
  end

  def call; end

  def human_errors
    @errors.join(", ")
  end

  private
    def add_errors(*errors)
      @errors.push(errors)

      @errors.flatten!
    end

    def object_class_from_parent
      class_name = self.class.object_class_name_from_parent

      return unless @object_class_from_parent || Object.const_defined?(class_name)

      @object_class_from_parent ||= class_name.constantize
    end
end
