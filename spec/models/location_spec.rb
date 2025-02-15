# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Location, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:location_informations).dependent :nullify }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:latitude) }
    it { is_expected.to validate_presence_of(:longitude) }

    describe 'uniqueness on name' do
      let(:name) { 'Lisbon' }

      it 'raises active record validation when name is already used' do
        create :location, name: name
        another_location = described_class.new(name: name,
                                               latitude: 38.71667,
                                               longitude: -9.13333)
        expect do
          another_location.save!
        end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: '\
        'Name has already been taken')
        expect(another_location.errors.messages).to have_key(:name)
      end
    end
  end
end
