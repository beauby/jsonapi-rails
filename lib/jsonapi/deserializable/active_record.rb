# frozen_string_literal: true
require 'jsonapi/deserializable'

module JSONAPI
  module Deserializable
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
    class ActiveRecord
      require_relative 'active_record/builder'

      class << self
        def deserializable_cache
          @deserializable_cache ||= {}
        end

        # Creates a DeserializableResource class based off all the
        # attributes and relationships
        #
        # @example
        #   JSONAPI::Deserializable::ActiveRecord[Post].new(params)
        def [](klass)
          deserializable_cache[klass.name] ||= deserializable_for(klass)
        end

        def deserializable_for(klass)
          JSONAPI::Deserializable::ActiveRecord::Builder.for_class(klass)
        end

        def deserializable_class(type, klass)
          klass || type_to_model(type)
        end

        def type_to_model(type)
          type.classify.safe_constantize
        end
      end

      # if this class is instatiated directly, i.e.: without a spceified
      # class via
      #  JSONAPI::Deserializable::ActiveRecord[ExampleClass]
      # then when to_hash is called, the class will be derived, and
      # a class will be used for deserialization as if the
      # user specified the deserialization target class.
      def initialize(hash, options: {}, klass: nil)
        @hash = hash
        @options = options
        @klass = klass
      end

      def to_hash
        type = @hash['data']['type']
        klass = self.class.deserializable_class(type, @klass)

        if klass.nil?
          raise "FATAL: class not found for type of `#{type}` or specified @klass `#{@klass&.name}`"
        end

        self.class[klass].call(@hash).with_indifferent_access
      end
    end
  end
end
