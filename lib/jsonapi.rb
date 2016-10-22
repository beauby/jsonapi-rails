module JSONAPI
  require_relative 'jsonapi/rails'

  module_function

  def to_active_record_hash(hash, options: {}, klass: nil)

    # TODO: maybe JSONAPI::Document::Deserialization.to_active_record_hash(...)?
    JSONAPI::Rails::Deserialization.to_active_record_hash(
      hash,
      options: options,
      klass: klass
    )
  end
end
