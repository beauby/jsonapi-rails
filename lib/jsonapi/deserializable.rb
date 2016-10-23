module JSONAPI
  module Deserializable
    require_relative 'deserializable/active_record'

    module_function

    def to_active_record_hash(hash, options: {}, klass: nil)

      # TODO: maybe JSONAPI::Document::Deserialization.to_active_record_hash(...)?
      JSONAPI::Deserializable::ActiveRecord.new(
        hash,
        options: options,
        klass: klass
      ).to_hash
    end
  end
end
