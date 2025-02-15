require 'rails_helper'

RSpec.describe LocationInformation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:location)}
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_date) }
    it { is_expected.to validate_presence_of(:end_date) }
  end
end
