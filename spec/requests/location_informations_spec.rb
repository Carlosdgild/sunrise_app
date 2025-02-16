# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationInformationsController, type: :controller do
  describe 'GET /location_informations/information_range' do
    let(:location) { create :location, name: 'Porto' }
    let(:another_location) { create :location, name: 'Lisbon'}

    it 'retrieves information for a location according to given dates' do
      get :information_range,
        params: { location_name: 'Lisbon', start_date: '01-01-2024', end_date: '31-01-2024' }
      body = response.body
      body = JSON.parse(body)
      expect(body.count).to eq(31)
    end

    it 'raise error when start_date missing' do
      expect do
        get :information_range,
          params: { location_name: 'Lisbon', end_date: '31-01-2024' }
      end.to raise_error(ActionController::ParameterMissing)
    end

    it 'raise error when end_date missing' do
      expect do
        get :information_range,
          params: { location_name: 'Lisbon', start_date: '31-01-2024' }
      end.to raise_error(ActionController::ParameterMissing)
    end

    it 'raise error when occurs an error fetching coordinates' do
      expect do
        get :information_range,
        params: { location_name: 'Lisbon', start_date: '01-01-2024', end_date: '31-01-2024' }
      end.to raise
    end
  end
end
