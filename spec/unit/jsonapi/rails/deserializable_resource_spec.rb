describe JSONAPI::Rails::DeserializableResource do
  let(:klass) { JSONAPI::Rails::DeserializableResource }
  describe '.[]' do
    context 'creates a DeserializableResource'
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

  describe '.new' do
    it 'caches generated classes' do

    end
  end

  describe '#to_h' do

  end

  describe '#attributes_for_class' do

  end

  describe '#associations_for_class' do

  end

  describe '#class_for_deserialization' do

  end

  describe '#type_to_model' do

  end

  context 'options' do
    context 'polymorphic' do

    end

    context 'whitelist fields' do

    end
  end
end
