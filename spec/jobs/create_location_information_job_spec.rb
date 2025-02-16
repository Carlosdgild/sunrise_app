# frozen_string_literal: true

describe CreateLocationInformationJob, type: :job do
  let(:results) do
    [{ 'date' => '2024-01-01',
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
     { 'date' => '2024-01-02',
       'sunrise' => '7:55:46 AM',
       'sunset' => '5:26:06 PM',
       'first_light' => '6:20:25 AM',
       'last_light' => '7:01:27 PM',
       'dawn' => '7:26:00 AM',
       'dusk' => '5:55:51 PM',
       'solar_noon' => '12:40:56 PM',
       'golden_hour' => '4:44:28 PM',
       'day_length' => '9:30:20',
       'timezone' => 'Europe/Lisbon',
       'utc_offset' => 0 }]
  end
  let(:location) { create :location }

  describe 'perform' do
    context 'when params are not given' do
      it 'raises error when location id does not exist' do
        expect(Rails.logger).to receive(:error)
        expect do
          described_class.perform_now(9999, results)
        end.not_to(change(LocationInformation, :count))
      end

      it 'raises error when result not given' do
        expect(Rails.logger).to receive(:error)
        expect do
          described_class.perform_now(location.id, nil)
        end.not_to(change(LocationInformation, :count))
      end
    end

    context 'when there is an error when creating LocationInformation' do
      before do
        allow(LocationInformation).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'register error and go with next value' do
        expect(Rails.logger).to receive(:error).twice
        expect do
          described_class.perform_now(location.id, results)
        end.not_to(change(LocationInformation, :count))
      end
    end

    context 'when locations do not exist' do
      it 'create location information for all results' do
        expect do
          described_class.perform_now(location.id, results)
        end.to change(LocationInformation, :count).by(2)
      end
    end

    context 'when locations exists' do
      before do
        create :location_information, location_id: location.id, information_date: '2024-01-01'
      end

      it 'creates location information for new results' do
        expect do
          described_class.perform_now(location.id, results)
        end.to change(LocationInformation, :count).by(1)
        expect(LocationInformation.last.information_date.to_s).to eq('2024-01-02')
      end
    end
  end
end
