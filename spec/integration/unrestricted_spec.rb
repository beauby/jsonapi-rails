# frozen_string_literal: true
describe JSONAPI::Rails::DeserializableResource::Unrestricted do
  let(:klass) { JSONAPI::Rails::DeserializableResource::Unrestricted }

  describe '.to_active_record_hash' do
    it 'uses unrestricted deserialization when a type is not found' do
      hash = {
        'data' => {
          'type' => 'restraints',
          'relationships' => {
            'restriction_for' => {
              'data' => {
                'type' => 'discounts',
                'id' => '67'
              }
            }
          }
        }
      }
      actual = JSONAPI::Rails.to_active_record_hash(hash)

      expected = {
        'restriction_for_id' => '67',
        'restriction_for_type' => 'discounts'
      }
      expect(actual).to eq expected
    end

    it 'deserializes just the relationships' do
      hash = {
        'data' => {
          'type' => 'restraints',
          'relationships' => {
            'restriction_for' => {
              'data' => {
                'type' => 'discounts',
                'id' => '67'
              }
            },
            'restricted_to' => {
              'data' => nil
            }
          }
        }
      }


      expected = {
        'restriction_for_id' => '67',
        'restriction_for_type' => 'discounts',
        'restricted_to_id' => nil,
        'restricted_to_type' => nil
      }
      actual = klass.to_active_record_hash(hash)
      expect(actual).to eq expected
    end

    it 'deserializes attributes and relationships' do
      hash = {
        'data' => {
          'type' => 'photos',
          'id' => 'zorglub',
          'attributes' => {
            'title' => 'Ember Hamster',
            'src' => 'http://example.com/images/productivity.png',
            'image_width' => '200',
            'image_height' => '200',
            'image_size' => '1024'
          },
          'relationships' => {
            'author' => {
              'data' => nil
            },
            'photographer' => {
              'data' => { 'type' => 'people', 'id' => '9' }
            },
            'comments' => {
              'data' => [
                { 'type' => 'comments', 'id' => '1' },
                { 'type' => 'comments', 'id' => '2' }
              ]
            },
            'related_images' => {
              'data' => [
                { 'type' => 'image', 'id' => '7' },
                { 'type' => 'image', 'id' => '8' }
              ]
            }
          }
        }
      }

      actual = klass.to_active_record_hash(hash)

      expected = {
        'id' => 'zorglub',
        'title' => 'Ember Hamster',
        'src' => 'http://example.com/images/productivity.png',
        'image_width' => '200',
        'image_height' => '200',
        'image_size' => '1024',
        'author_id' => nil,
        'author_type' => nil,
        'photographer_id' => '9',
        'photographer_type' => 'people',
        'comment_ids' => %w(1 2),
        'related_image_ids' => %w(7 8)
      }

      expect(actual).to eq expected
    end
  end
end
