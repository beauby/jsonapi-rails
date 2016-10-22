require 'jsonapi/deserializable'

module JSONAPI
  module Rails
    # This does not validate a JSON API document, so errors may happen.
    # To truely ensure valid documents are used, it would be recommended to
    # use either of
    #  - JSONAPI::Parser - for general parsing and validating
    #  - JSONAPI::Validations - for defining validation logic.
    #
    # for 'filtereing' of fields, use ActionController::Parameters
    #
    # TODO:
    #  - add option for type-seperator string
    #  - add options for specifying polymorphic relationships
    #    - this will try to be inferred based on the klass's associations
    #  - cache deserializable_for_class
    #  - allow custom deserializable_classes?
    #    - then this gem would just be a very light weight wrapper around
    #      jsonapi/deserializable
    class DeserializableResource < JSONAPI::Deserializable::Resource
      require_relative 'deserializable_resource/builder'

      include Builder

      class << self
        def deserializable_cache
          @deserializable_cache ||= {}
        end

        # Creates a DeserializableResource class based off all the
        # attributes and relationships
        #
        # @example
        #   JSONAPI::Rails::DeserializableResource[Post].new(params)
        def [](klass)
          deserializable_cache[klass.name] ||= deserializable_for(klass)
        end

        def deserializable_for(klass)
          DeserializableResource::Builder.for_class(klass)
        end
      end

      attr_accessor :_hash, :_options, :_klass

      # if this class is instatiated directly, i.e.: without a spceified
      # class via
      #  JSONAPI::Rails::DeserializableResource[ExampleClass]
      # then when to_hash is called, the class will be derived, and
      # a class will be used for deserialization as if the
      # user specified the deserialization target class.
      def initialize(hash, options: {}, klass: nil)
        @_hash = hash
        @_options = options
        @_klass = klass
      end

      def to_hash
        type = _hash['data']['type']
        klass = deserializable_class(type, _klass)

        self.class.deserializable_for(klass).new(
          hash,
          options: _options
        ).to_h
      end

      private

      def deserializable_class(type, klass)
        klass || type_to_model(type)
      end

      def type_to_model(type)
        type.classify.constantize
      end
    end
  end
end
