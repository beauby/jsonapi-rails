module JSONAPI
  module Rails
    require_relative 'rails/deserializable_resource'

    module_function

    def to_active_record_hash(hash, options: {}, klass: nil)

      # TODO: maybe JSONAPI::Document::Deserialization.to_active_record_hash(...)?
      JSONAPI::Rails::DeserializableResource.new(
        hash,
        options: options,
        klass: klass
      ).to_hash
    end
  end
end
