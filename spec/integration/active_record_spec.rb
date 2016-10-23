require 'spec_helper'

describe JSONAPI::Deserializable::ActiveRecord do
  let(:klass) { JSONAPI::Deserializable::ActiveRecord }

  around(:each) do |example|
    with_temporary_database(lambda do
                              create_table :posts do |t|
                                t.string :name
                                t.string :body
                                t.references :author, polymorphic: true
                              end

                              create_table :users do |t|
                                t.string :name
                              end
                            end) do
      # Clear cache just in case a test runs before this one
      klass.instance_variable_set('@deserializable_cache', {})
      class Post < ActiveRecord::Base; belongs_to :author, polymorphic: true; end
      class User < ActiveRecord::Base; has_many :posts; end
      example.run
    end
  end

  after(:each) do
    # clear the cache, just in case the next test needs
    # to interact with the cache
    klass.instance_variable_set('@deserializable_cache', {})
  end

  context 'deserializing a jsonapi document' do
    context 'with attributes' do
      before(:all) do
        @payload = {
          'data' => {
            'id' => '1',
            'type' => 'posts',
            'attributes' => {
              'name' => 'Name',
              'body' => 'content'
            },
            'relationships' => {}
          }
        }
      end

      it 'pulls out the attributes' do
        result = JSONAPI::Deserializable.to_active_record_hash(@payload, options: {}, klass: Post)
        expected = { 'name' => 'Name', 'body' => 'content' }

        expect(result).to eq expected
      end
    end

    context 'with polymorphic relationships' do
      before(:all) do
        @payload = {
          'data' => {
            'id' => '1',
            'type' => 'posts',
            'attributes' => {
              'name' => 'Name',
              'body' => 'content'
            },
            'relationships' => {
              'author' => {
                'data' => {
                  'id' => 1,
                  'type' => 'users'
                }
              }
            }
          }
        }
      end

      it 'pulls out the attributes' do
        result = JSONAPI::Deserializable.to_active_record_hash(@payload, options: {}, klass: Post)
        expected = {
          'name' => 'Name',
          'body' => 'content',
          'author_id' => 1,
          'author_type' => 'User'
        }

        expect(result).to eq expected
      end
    end
  end
end
