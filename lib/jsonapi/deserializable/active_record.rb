module JSONAPI
  module Deserializable
    class ActiveRecord < Resource
      def deserialize_has_one_rel!(rel, &block)
        id = rel['data'] && rel['data']['id']
        type = rel['data'] && rel['data']['type'].singularize.constantize
        instance_exec(rel, id, type, &block)
      end

      def deserialize_has_many_rel!(rel, &block)
        ids = rel['data'].map { |ri| ri['id'] }
        types = rel['data'].map { |ri| ri['type'].singularize.constantize }
        instance_exec(rel, ids, types, &block)
      end
    end
  end
end
