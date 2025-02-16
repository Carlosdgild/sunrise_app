# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationInformation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:location) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:information_date) }
  end

  describe '.filter_by_start_and_end_date' do
    let(:location) { create :location }
    let!(:first_location_information) do
      create :location_information, location: location, information_date: '2025-02-14'
    end
    let!(:second_location_information) do
      create :location_information, location: location, information_date: '2025-02-16'
    end

    it 'retrieves records for the given params' do
      results =
        described_class.filter_by_start_and_end_date(location.id, '2025-02-10', '2025-02-20')
      expect(results.count).to eq(2)
      ids = results.pluck(:id)
      expect(ids).to include(first_location_information.id)
      expect(ids).to include(second_location_information.id)
    end

    it 'do not retrieve records for the given params' do
      results =
        described_class.filter_by_start_and_end_date(location.id, '2025-08-10', '2025-08-20')
      expect(results.count).to eq(0)
      expect(described_class.count).to eq(2)
    end
  end
end
