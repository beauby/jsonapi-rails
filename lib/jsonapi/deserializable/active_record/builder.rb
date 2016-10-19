require 'jsonapi/deserializable/resource'

module JSONAPI
  module Deserializable
    class ActiveRecord
      module Builder
        require 'active_support/core_ext/string'

        module_function

        def for_class(klass)
          builder = self
          Class.new(JSONAPI::Deserializable::Resource) do
            # All Attributes
            builder.define_attributes(self, klass)

            # All Associations
            builder.define_associations(self, klass)
          end
        end

        def define_attributes(deserializable, klass)
          attributes = attributes_for_class(klass)

          deserializable.class_eval do
            attributes.each do |attribute_name|
              attribute attribute_name
            end
          end
        end

        def define_associations(deserializable, klass)
          associations = associations_for_class(klass)

          deserializable.class_eval do
            associations.each do |name, reflection|
              if reflection.collection?
                has_many name do |rel|
                  field "#{name}_ids" => rel['data'].map { |ri| ri['id'] }
                  # field "#{name}_type" => rel['data'] && rel['data']['type']
                end
              else
                has_one name do |rel|
                  field "#{name}_id" => rel['data'] && rel['data']['id']

                  if reflection.polymorphic?
                    field "#{name}_type" => rel['data'] && rel['data']['type'].classify
                  end
                end
              end
            end
          end
        end

        def self.attributes_for_class(klass)
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
        def self.associations_for_class(klass)
          klass.reflections
        end
      end # Builder
    end # DeserializableResource
  end # Rails
end # JSONAPI
