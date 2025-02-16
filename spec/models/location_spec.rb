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
        end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: ' \
                                                        'Name has already been taken')
        expect(another_location.errors.messages).to have_key(:name)
      end
    end
  end

  describe '.create_location_record_with_coordinates' do
    context 'when all parameters are given' do
      it 'creates a new Location' do
        expect do
          described_class.create_location_record_with_coordinates!('name', 1.2, 3.4)
        end.to change(described_class, :count).by(1)
      end
    end

    context 'when a parameter is missing' do
      it 'raises error when name is missing' do
        expect do
          described_class.create_location_record_with_coordinates!(nil, 1.2, 3.4)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'raises error when latitude is missing' do
        expect do
          described_class.create_location_record_with_coordinates!('name', nil, 3.4)
        end.to raise_error(ArgumentError)
      end

      it 'raises error when longitude is missing' do
        expect do
          described_class.create_location_record_with_coordinates!('name', 1.2, nil)
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe '.create_new_location!' do
    let(:location_name) { 'Porto' }
    let(:latitude) { 40.7128 }
    let(:longitude) { -74.0060 }

    context 'when latitude and logitude are given' do
      it 'calls create_location_record_with_coordinates!' do
        expect(described_class).to receive(:create_location_record_with_coordinates!)
          .with(location_name, latitude, longitude)
        described_class.create_new_location!(location_name, latitude, longitude)
      end
    end

    context 'when latitude and logitude are missing' do
      it 'calls LocationCoordinatesService.call! when latitude missing' do
        expect(LocationCoordinatesService).to receive(:call!).with(location_name)
        described_class.create_new_location!(location_name, nil, longitude)
      end

      it 'calls LocationCoordinatesService.call! when longitude missing' do
        expect(LocationCoordinatesService).to receive(:call!).with(location_name)
        described_class.create_new_location!(location_name, 0.2, nil)
      end
    end
  end
end
