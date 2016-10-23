module JSONAPI
  module Rails
    class DeserializableResource
      # Taken and stripped down from ActiveModelSerializers
      # 0.10.2
      #
      # For use when a type in ruby is not present.
      # - it is dangerous to use this, as it may lead to corrupt data
      #   (nothing is whitelisted based on type)
      # - Strongy encourage the use of strang parameters in conjunction with this
      # - the relationship type is always returned, because there is no way
      #   to test if the relationsihp is polymorphic or not
      module Unrestricted
        module_function

        def to_active_record_hash(document)
          primary_data = document['data']
          attributes = primary_data['attributes'] || {}
          attributes['id'] = primary_data['id'] if primary_data['id']
          relationships = primary_data['relationships'] || {}

          hash = {}
          hash.merge!(parse_attributes(attributes))
          hash.merge!(parse_relationships(relationships))

          hash.with_indifferent_access
        end

        def parse_attributes(attributes)
          attributes
            # .map { |(k, v)| { k => v } }
            # .reduce({}, :merge)
        end


        # Given an association name, and a relationship data attribute, build a hash
        # mapping the corresponding ActiveRecord attribute to the corresponding value.
        #
        # @example
        #   parse_relationship(:comments, [{ 'id' => '1', 'type' => 'comments' },
        #                                  { 'id' => '2', 'type' => 'comments' }],
        #                                 {})
        #    # => { :comment_ids => ['1', '2'] }
        #   parse_relationship(:author, { 'id' => '1', 'type' => 'users' }, {})
        #    # => { :author_id => '1' }
        #   parse_relationship(:author, nil, {})
        #    # => { :author_id => nil }
        # @param [Symbol] assoc_name
        # @param [Hash] assoc_data
        # @param [Hash] options
        # @return [Hash{Symbol, Object}]
        #
        # @api private
        def parse_relationship(assoc_name, assoc_data)
          prefix_key = assoc_name.to_s.singularize
          hash =
            if assoc_data.is_a?(Array)
              { "#{prefix_key}_ids".to_sym => assoc_data.map { |ri| ri['id'] } }
            else
              { "#{prefix_key}_id".to_sym => assoc_data ? assoc_data['id'] : nil }
            end

          unless assoc_data.is_a?(Array)
            hash["#{prefix_key}_type".to_sym] = assoc_data.present? ? assoc_data['type'] : nil
          end

          hash
        end

        # @api private
        def parse_relationships(relationships)
          relationships
            .map { |(k, v)| parse_relationship(k, v['data']) }
            .reduce({}, :merge)
        end
      end # Unrestricted
    end # DeserializableResource
  end # Rails
end # JSONAPI
