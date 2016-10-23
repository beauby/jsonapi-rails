require 'spec_helper'

describe JSONAPI::Rails::DeserializableResource do
  let(:klass) { JSONAPI::Rails::DeserializableResource }

  around(:each) do |example|
    with_temporary_database(lambda do
                              create_table :posts
                            end) do
      # Clear cache just in case a test runs before this one
      klass.instance_variable_set('@deserializable_cache', {})
      class Post < ActiveRecord::Base; end
      example.run
    end
  end

  after(:each) do
    # clear the cache, just in case the next test needs
    # to interact with the cache
    klass.instance_variable_set('@deserializable_cache', {})
  end

  context 'deserializing a jsonapi document' do
    before(:all) do
      @payload = {
        'data' => {
          'id' => '1',
          'type' => 'posts',
          'attributes' => {
            'name' => 'Name',
            'body' => 'content'
          }
        }
      }
    end

    it 'pulls out the attributes' do
      result = JSONAPI::Rails.to_active_record_hash(@payload, options: {}, klass: Post)
      expected = { 'name' => 'Name', 'body' => 'content' }

      expect(result).to eq expected
    end
  end
end
