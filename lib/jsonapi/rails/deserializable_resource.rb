# frozen_string_literal: true
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
    class DeserializableResource
      require_relative 'deserializable_resource/builder'
      require_relative 'deserializable_resource/unrestricted'

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

        def unrestricted_deserialization(hash)
          DeserializableResource::Unrestricted.to_active_record_hash(hash)
        end

        def deserializable_class(type, klass)
          klass || type_to_model(type)
        end

        def type_to_model(type)
          type.classify.safe_constantize
        end
      end

      attr_accessor :_hash, :_options, :_klass

      # if this class is instatiated directly, i.e.: without a spceified
      # class via
      #  JSONAPI::Rails::DeserializableResource[ExampleClass]
      # then when to_hash is called, the class will be derived, and
      # a class will be used for deserialization as if the
      # user specified the deserialization target class.
      #
      # Note that by specifying klass to false, no class will be used.
      # This means that every part of the JSONAPI Document will be
      # deserialized, and none of it will be whitelisted against any
      # class
      def initialize(hash, options: {}, klass: nil)
        @_hash = hash
        @_options = options
        @_klass = klass
      end

      def to_hash
        type = _hash['data']['type']
        klass = self.class.deserializable_class(type, _klass)

        if _klass == false || klass.nil?
          puts "WARNING: class not found for type of `#{type}` or specified _klass `#{_klass&.name}`"
          return self.class.unrestricted_deserialization(_hash)
        end

        self.class[klass].call(_hash).with_indifferent_access
      end
    end
  end
end
