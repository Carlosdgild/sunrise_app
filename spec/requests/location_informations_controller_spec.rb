# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationInformationsController, type: :request do
  describe 'GET /location_informations/information_range' do
    let(:location) { create :location, name: 'Porto' }
    let(:another_location) { create :location, name: 'Lisbon' }
    let(:url) { information_range_location_informations_url }
    let(:params) do
      {
        location_name: 'Lisbon',
        start_date: '01-01-2024',
        end_date: '31-01-2024'
      }
    end

    it 'retrieves information for a location according to given dates' do
      expect(CoordinateApiClient)
        .to receive(:fetch_coordinates)
        .and_call_original
      expect(SunriseSunsetApiClient)
        .to receive(:fetch_information_for_location)
        .and_call_original
      expect do
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            get url, params: params
          end
        end
      end.to have_enqueued_job(CreateLocationInformationJob)
      expect(response).to have_http_status(:ok)
      location_information_data = json
      expect(location_information_data.count).to eq(31)
      # Database expectations
      expect(Location.count).to eq(1)
      expect(LocationInformation.count).to eq(0)
    end

    it 'retrieves information for a location according to given dates and creates ' \
       'in background location information', :perform_enqueued do
      expect(CoordinateApiClient)
        .to receive(:fetch_coordinates)
        .and_call_original
      expect(SunriseSunsetApiClient)
        .to receive(:fetch_information_for_location)
        .and_call_original
      expect do
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            get url, params: params
          end
        end
      end.not_to have_enqueued_job(CreateLocationInformationJob)
      expect(response).to have_http_status(:ok)
      location_information_data = json
      expect(location_information_data.count).to eq(31)
      # Database expectations
      expect(Location.count).to eq(1)
      expect(LocationInformation.count).to eq(31)
    end

    it 'retrieves information for a location according to given dates, and dates ' \
       'are yyyy-mm-dd format' do
      expect(CoordinateApiClient)
        .to receive(:fetch_coordinates)
        .and_call_original
      expect(SunriseSunsetApiClient)
        .to receive(:fetch_information_for_location)
        .and_call_original
      expect do
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            get url,
                params: { location_name: 'Lisbon', start_date: '2024-01-01',
                          end_date: '2024-01-31' }
          end
        end
      end.to have_enqueued_job(CreateLocationInformationJob)
      expect(response).to have_http_status(:ok)
      location_information_data = json
      expect(location_information_data.count).to eq(31)
      # Database expectations
      expect(Location.count).to eq(1)
      expect(LocationInformation.count).to eq(0)
    end

    it 'retrieves information for a location according to given dates, and dates ' \
       'are yyyymmdd format' do
      expect(CoordinateApiClient)
        .to receive(:fetch_coordinates)
        .and_call_original
      expect(SunriseSunsetApiClient)
        .to receive(:fetch_information_for_location)
        .and_call_original
      expect do
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            get url,
                params: { location_name: 'Lisbon', start_date: '20240101',
                          end_date: '20240131' }
          end
        end
      end.to have_enqueued_job(CreateLocationInformationJob)
      expect(response).to have_http_status(:ok)
      location_information_data = json
      expect(location_information_data.count).to eq(31)
      # Database expectations
      expect(Location.count).to eq(1)
      expect(LocationInformation.count).to eq(0)
    end

    it 'retrieves information for a location according to given dates, and dates ' \
       'are yyyy/mm/dd format' do
      expect(CoordinateApiClient)
        .to receive(:fetch_coordinates)
        .and_call_original
      expect(SunriseSunsetApiClient)
        .to receive(:fetch_information_for_location)
        .and_call_original
      expect do
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            get url,
                params: { location_name: 'Lisbon', start_date: '2024/01/01',
                          end_date: '2024/01/31' }
          end
        end
      end.to have_enqueued_job(CreateLocationInformationJob)
      expect(response).to have_http_status(:ok)
      location_information_data = json
      expect(location_information_data.count).to eq(31)
      # Database expectations
      expect(Location.count).to eq(1)
      expect(LocationInformation.count).to eq(0)
    end

    it 'raises error when date format is ddmmyyy' do
      expect(CoordinateApiClient)
        .not_to receive(:fetch_coordinates)
        .and_call_original
      expect(SunriseSunsetApiClient)
        .not_to receive(:fetch_information_for_location)
        .and_call_original
      expect do
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            get url,
                params: { location_name: 'Lisbon', start_date: '01122024',
                          end_date: '31012024' }
          end
        end
      end.not_to have_enqueued_job(CreateLocationInformationJob)
      expect(response).to have_http_status(:bad_request)
      # Database expectations
      expect(Location.count).to eq(0)
      expect(LocationInformation.count).to eq(0)
    end

    it 'raises error when date format is not a date' do
      expect(CoordinateApiClient)
        .not_to receive(:fetch_coordinates)
        .and_call_original
      expect(SunriseSunsetApiClient)
        .not_to receive(:fetch_information_for_location)
        .and_call_original
      expect do
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            get url,
                params: { location_name: 'Lisbon', start_date: 'test',
                          end_date: 'test' }
          end
        end
      end.not_to have_enqueued_job(CreateLocationInformationJob)
      expect(response).to have_http_status(:bad_request)
      # Database expectations
      expect(Location.count).to eq(0)
      expect(LocationInformation.count).to eq(0)
    end

    it 'raise error when start_date missing' do
      get url, params: { location_name: 'Lisbon', end_date: '31-01-2024' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'raise error when end_date missing' do
      get url, params: { location_name: 'Lisbon', start_date: '31-01-2024' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'raise error when occurs an error fetching coordinates' do
      allow(CoordinateApiClient)
        .to receive(:fetch_coordinates)
        .and_return([nil, 'error'])
      get url,
          params: { location_name: 'NoLocation', start_date: '01-01-2024', end_date: '31-01-2024' }
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'unprocessable_entity when diff between dates is more than 365 days' do
      expect(CoordinateApiClient)
        .not_to receive(:fetch_coordinates)
        .and_call_original
      expect(SunriseSunsetApiClient)
        .not_to receive(:fetch_information_for_location)
        .and_call_original
      get url,
          params: { location_name: 'Lisbon', start_date: '2024-01-01', end_date: '2026-01-31' }
      expect(response).to have_http_status(:unprocessable_entity)
      # Database expectations
      expect(Location.count).to eq(0)
      expect(LocationInformation.count).to eq(0)
    end

    it 'unprocessable_entity when end_date is before start_date' do
      expect(CoordinateApiClient)
        .not_to receive(:fetch_coordinates)
        .and_call_original
      expect(SunriseSunsetApiClient)
        .not_to receive(:fetch_information_for_location)
        .and_call_original
      get url,
          params: { location_name: 'Lisbon', start_date: '2024-01-01', end_date: '2023-01-31' }
      expect(response).to have_http_status(:unprocessable_entity)
      # Database expectations
      expect(Location.count).to eq(0)
      expect(LocationInformation.count).to eq(0)
    end

    describe 'when coordinates given in params' do
      let(:params) do
        {
          location_name: 'Lisbon',
          start_date: '01-01-2024',
          end_date: '31-01-2024',
          latitude: '38.7077507',
          longitude: '-9.1365919'
        }
      end

      it 'do request to get information with given coordinates' do
        expect(CoordinateApiClient)
          .not_to receive(:fetch_coordinates)
          .and_call_original
        expect(SunriseSunsetApiClient)
          .to receive(:fetch_information_for_location)
          .and_call_original
        expect do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            get url, params: params
          end
        end.to have_enqueued_job(CreateLocationInformationJob)
        expect(response).to have_http_status(:ok)
        location_information_data = json
        expect(location_information_data.count).to eq(31)
        # Database expectations
        expect(Location.count).to eq(1)
        expect(LocationInformation.count).to eq(0)
      end
    end
  end
end
