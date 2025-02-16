# frozen_string_literal: true

describe RetrieveLocationInformationService, type: :service do
  let(:porto_name) { 'Porto' }
  let(:lisbon_name) { 'Lisbon' }
  let(:latitude) { 38.7077507 }
  let(:longitude) { -9.1365919 }
  let(:start_date) { '2024-01-01' }
  let(:end_date) { '2024-01-31' }

  describe 'when no given the required params' do
    it 'when no given start date' do
      expect do
        described_class.call!(porto_name, latitude, longitude, nil, end_date)
      end.to raise_error(CustomStandardError)
      expect(Location.count).to eq(0)
    end

    it 'when no given end date' do
      expect do
        described_class.call!(porto_name, latitude, longitude, start_date, nil)
      end.to raise_error(CustomStandardError)
      expect(Location.count).to eq(0)
    end

    it 'when no given location name' do
      expect do
        described_class.call!(nil, latitude, longitude, start_date, end_date)
      end.to raise_error(CustomStandardError)
      expect(Location.count).to eq(0)
    end
  end

  context 'when required data is in the database' do
    before do
      location = create(:location, name: porto_name, latitude: latitude, longitude: longitude)
      create(:location_information, information_date: '2024-01-23', location: location)
      create(:location_information, information_date: '2024-01-24', location: location)
    end

    describe 'when is completely in the database' do
      it 'just retrieve information from database', :perform_enqueued do
        expect(CoordinateApiClient)
          .not_to receive(:fetch_coordinates)
          .and_call_original
        expect(SunriseSunsetApiClient)
          .not_to receive(:fetch_information_for_location)
          .and_call_original
        results = described_class.call!(
          porto_name, latitude, longitude, '2024-01-23', '2024-01-24'
        )
        expect(results.count).to eq(2)
        expect(LocationInformation.count).to eq(2)
      end
    end

    describe 'when is not completly in the database' do
      it 'do a request to retrieve information from sunrisesunset api', :perform_enqueued do
        results = nil
        expect(CoordinateApiClient)
          .not_to receive(:fetch_coordinates)
          .and_call_original
        expect(SunriseSunsetApiClient)
          .to receive(:fetch_information_for_location)
          .and_call_original
        VCR.use_cassette('lisbon_days_information',
                         match_requests_on: [:sunrisesunset]) do
          results =
            described_class.call!(porto_name, latitude, longitude, start_date, end_date)
        end
        expect(results.count).to eq(31)
        expect(Location.count).to eq(1)
        expect(LocationInformation.count).to eq(31)
      end

      it 'do a request only to retrieve information from sunrisesunset api when ' \
         'latitude and logitude are given', :perform_enqueued do
        results = nil
        expect(CoordinateApiClient)
          .not_to receive(:fetch_coordinates)
          .and_call_original
        expect(SunriseSunsetApiClient)
          .to receive(:fetch_information_for_location)
          .and_call_original
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            results =
              described_class.call!(lisbon_name, latitude, longitude, start_date, end_date)
          end
        end
        expect(results.count).to eq(31)
        expect(Location.count).to eq(2)
        # 2 locations from Porto location, and 31 for Lisbon
        expect(LocationInformation.count).to eq(33)
        location = Location.last
        expect(location.name).to eq('Lisbon')
        expect(LocationInformation.where(location_id: location.id).count).to eq(31)
      end

      it 'do a request to retrieve information from openstreetmap and sunrisesunset api ' \
         'when no location found nor latitude given', :perform_enqueued do
        results = nil
        expect(CoordinateApiClient)
          .to receive(:fetch_coordinates)
          .and_call_original
        expect(SunriseSunsetApiClient)
          .to receive(:fetch_information_for_location)
          .and_call_original
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            results =
              described_class.call!(lisbon_name, nil, longitude, start_date, end_date)
          end
        end
        expect(results.count).to eq(31)
        expect(Location.count).to eq(2)
        # 2 locations from Porto location, and 31 for Lisbon
        expect(LocationInformation.count).to eq(33)
      end
    end
  end

  context 'when doing request to sunrisesunset api fails' do
    it 'raises error but persist the location', :perform_enqueued do
      results = nil
      # destroying locations to ensure that one will be created
      Location.destroy_all
      result_with_error = [{ 'date' => '2024-01-01',
                             'sunrise' => '7:55:35 AM',
                             'sunset' => '5:25:21 PM',
                             'first_light' => '6:20:11 AM',
                             'last_light' => '7:00:45 PM',
                             'dawn' => '7:25:49 AM',
                             'dusk' => '5:55:08 PM',
                             'solar_noon' => '12:40:28 PM',
                             'golden_hour' => '4:43:40 PM',
                             'day_length' => '9:29:45',
                             'timezone' => 'Europe/Lisbon',
                             'utc_offset' => 0 },
                           { error: 'error' }]
      allow(SunriseSunsetApiClient)
        .to receive(:fetch_information_for_location)
        .and_return(result_with_error)
      expect(CoordinateApiClient)
        .to receive(:fetch_coordinates)
        .and_call_original
      expect do
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            results = described_class.call!(lisbon_name, nil, longitude, start_date, end_date)
          end
        end
      end.to raise_error(CustomStandardError)
      expect(results).to be_nil
      expect(Location.count).to eq(1)
      # Zero since it raises error fetching data
      expect(LocationInformation.count).to eq(0)
    end
  end

  context 'when doing request to openstreetmap api fails' do
    it 'raises error but anything persist at database', :perform_enqueued do
      results = nil
      # destroying locations to ensure that none will be created
      Location.destroy_all
      allow(SunriseSunsetApiClient)
        .to receive(:fetch_information_for_location)
        .and_call_original
      allow(CoordinateApiClient)
        .to receive(:fetch_coordinates)
        .and_return(%w[anything error])
      expect do
        VCR.use_cassette('lisbon_coordinates',
                         match_requests_on: [:openstreetmap]) do
          VCR.use_cassette('lisbon_days_information',
                           match_requests_on: [:sunrisesunset]) do
            results = described_class.call!(lisbon_name, nil, longitude, start_date, end_date)
          end
        end
      end.to raise_error(CustomStandardError)
      expect(results).to be_nil
      # Zero since it raises error fetching data
      expect(Location.count).to eq(0)
      expect(LocationInformation.count).to eq(0)
    end
  end
end
