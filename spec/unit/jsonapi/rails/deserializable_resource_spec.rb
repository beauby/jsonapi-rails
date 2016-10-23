describe JSONAPI::Rails::DeserializableResource do
  let(:klass) { JSONAPI::Rails::DeserializableResource }
  describe '.[]' do
    context 'creates a DeserializableResource class' do
      around(:each) do |example|
        with_temporary_database(lambda do
                                  create_table :posts do |t|
                                    t.string :title
                                  end
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

      it 'without a specified type' do
        json = {
          'data' => {
            'id' => 1,
            'type' => 'posts',
            'attributes' => {
              'title' => 'a title'
            }
          }
        }

        expect { klass.new(json).to_hash }
          .to change(klass.deserializable_cache, :length).by 1

        expect(klass.deserializable_cache.keys.first).to eq 'Post'
      end

      it 'changes the cache' do
        expect(klass).to receive(:deserializable_for).once.and_call_original

        expect { klass[Post] }
          .to change(klass.deserializable_cache, :length).by 1
      end

      it 'does not add to the cache' do
        expect(klass).to receive(:deserializable_for).once.and_call_original

        expect { 3.times { klass[Post] } }
          .to change(klass.deserializable_cache, :length).by 1
      end
    end
  end

  describe '.new' do
    it 'caches generated classes' do

    end
  end

  describe '#to_h' do

  end

  context 'options' do
    context 'polymorphic' do

    end

    context 'whitelist fields' do

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
