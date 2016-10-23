# frozen_string_literal: true
describe JSONAPI::Rails::DeserializableResource::Builder do
  let(:klass) { JSONAPI::Rails::DeserializableResource::Builder }

  describe '.for_class' do
    it 'returns a DeserializableResource' do
      with_temporary_database(lambda do
                                create_table :posts
                              end) do
        class Post < ActiveRecord::Base; end
        deserializer = klass.for_class(Post)

        dummy_payload = {
          'data' => {
            'id' => '1',
            'type' => 'posts',
            'attributes' => {}
          }
        }

        expect(deserializer.new(dummy_payload)).to be_a_kind_of JSONAPI::Deserializable::Resource
      end
    end

    it 'defines all the attributes' do
      with_temporary_database(lambda do
                                create_table :posts do |t|
                                  t.string :name
                                  t.string :body
                                end
                              end) do
        class Post < ActiveRecord::Base; end
        deserializer = klass.for_class(Post)
        # defined in JSONAPI/DeserializableResource
        result = deserializer.attr_blocks.keys
        expected = %w(id name body)
        expect(result).to eq expected
      end
    end

    it 'defines all relationships' do
      with_temporary_database(lambda do
                                create_table :posts do |t|
                                  t.string :name
                                  t.string :body
                                  t.references :author
                                end

                                create_table :comments do |t|
                                  t.references :post
                                end

                                create_table :authors
                              end) do
        class Author < ActiveRecord::Base; end
        class Comment < ActiveRecord::Base; end
        class Post < ActiveRecord::Base
          has_many :comments
          belongs_to :author
        end

        deserializer = klass.for_class(Post)
        # defined in JSONAPI/DeserializableResource
        result_has_many = deserializer.has_many_rel_blocks.keys
        result_has_one = deserializer.has_one_rel_blocks.keys

        expect(result_has_many).to eq ['comments']
        expect(result_has_one).to eq ['author']
      end
    end
  end

  describe '.attributes_for_class' do
    it 'finds the attributes' do
      with_temporary_database(lambda do
                                create_table :posts do |t|
                                  t.text :body
                                  t.text :name
                                end
                              end) do
        class Post < ActiveRecord::Base; end
        attributes = klass.attributes_for_class(Post)

        expect(attributes).to eq %w(id body name)
      end
    end

    it 'finds the associations' do
      with_temporary_database(lambda do
                                create_table :posts do |t|
                                  t.references :post
                                end
                              end) do
        class Post < ActiveRecord::Base; belongs_to :post; end
        associations = klass.associations_for_class(Post)

        expect(associations.keys).to eq ['post']
      end
    end
  end
end
