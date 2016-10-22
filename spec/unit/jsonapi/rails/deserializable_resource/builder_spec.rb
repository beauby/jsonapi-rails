describe JSONAPI::Rails::DeserializableResource::Builder do
  let(:klass) { JSONAPI::Rails::DeserializableResource::Builder }

  describe '.for_class' do
    it 'can be instantiated' do
      with_temporary_database(lambda do
                                create_table :posts
                              end) do
        class Post < ActiveRecord::Base; end
        deserializer = klass.for_class(Post)

        expect(deserializer.new({})).to be_a_kind_of JSONAPI::Rails::DeserializableResource
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

  describe '.deserializable_class' do
    it 'returns klass if specified' do
      result = klass.deserializable_class('jsonapi-types', 'anything')

      expect(result).to eq 'anything'
    end
  end

  describe '.type_to_model' do
    class A; end
    class A::B; end
    class C < A; end
    class D < A::B; end

    let(:to_model) { ->(str) { klass.type_to_model(str) } }

    it 'converts plural types to a class' do
      expect(to_model.call('as')).to eq A
      expect(to_model.call('a/bs')).to eq A::B
      expect(to_model.call('cs')).to eq C
      expect(to_model.call('d')).to eq D
    end
  end
end
