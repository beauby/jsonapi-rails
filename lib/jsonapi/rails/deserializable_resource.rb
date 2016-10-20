require 'activesupport' # really just core_ext/string
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
          deserializable_cache[klass.name] ||= deserializable_for_class(klass)
        end

        def deserializable_for_class(klass)
          Class.new(JSONAPI::Rails::DeserializableResource) do
            # All Attributes
            optional do
              attributes_for_class(klass) do |attribute_name|
                attribute attribute_name
              end
            end

            # All Associations
            optional do
              associations_for_class(klass) do |name, reflection|
                if reflection.collection?
                  has_many name, reflection.class_name
                else
                  has_one name, reflection.class_name
                end
              end
            end
          end
        end
      end

      def initialize(hash, options: {}, klass: nil)

      end

      def to_active_record_hash(hash, options: {}, klass: nil)
        type = hash['data']['type']
        klass = deserializable_class(type, klass)

        deserializable_for_class(klass).new(hash).to_h
      end

      def deserializable_for_class(klass)
        Class.new(JSONAPI::Deserializable::Resource) do
          # All Attributes
          optional do
            attributes_for_class(klass) do |attribute_name|
              attribute attribute_name
            end
          end

          # All Associations
          optional do
            associations_for_class(klass) do |name, reflection|
              if reflection.collection?
                has_many name, reflection.class_name
              else
                has_one name, reflection.class_name
              end
            end
          end
        end
      end

      def attributes_for_class(klass)
        klass.columns.map(&:name)
      end

      # @return [Hash]
      #  example:
      #    {
      #      'author' => #<ActiveRecord::Reflection::BelongsToReflection ...>,
      #      'comments' => #<ActiveRecord::Reflection::HasManyReflection ...>
      #    }
      #
      # for a reflection, the import parts for deserialization may be as follows:
      #  - Reflection (BelongsTo / HasMany)
      #    - name - symbol version of the association name (e.g.: :author)
      #    - collection? - if the reflection is a collection of records
      #    - class_name - AR Class of the association
      #    - foreign_type - name of the polymorphic type column
      #    - foreign_key - name of the foreign_key column
      #    - polymorphic? - true/false/nil
      #    - type - name of the type column (for STI)
      #
      # To see a full list of reflection methods:
      #  ap klass.reflections['reflection_name'].methods - Object.methods
      def associations_for_class(klass)
        klass.reflections
      end

      def deserializable_class(type, klass)
        klass || type_to_model(type)
      end

      def type_to_model(type)
        type.classify.constantize
      end
    end
  end
end
