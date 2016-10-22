require 'active_support' # really just core_ext/string
# require 'activerecord'
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

      def initialize(hash, options: {}, klass: nil)
        self.class.deserializable_cache
      end

      def to_active_record_hash(hash, options: {}, klass: nil)
        type = hash['data']['type']
        klass = deserializable_class(type, klass)

        deserializable_for_class(klass).new(hash).to_h
      end
    end
  end
end
