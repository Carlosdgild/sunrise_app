# frozen_string_literal: true

FactoryBot.define do
  factory :location_information do
    location
    start_date { Time.current.strftime('%d-%m-%Y') }
    end_date { Time.current.advance(days: 1).strftime('%d-%m-%Y') }
    sunrise { Time.current }
    sunset { Time.current }
    first_light { Time.current }
    last_light { Time.current }
    dawn { Time.current }
    dusk { Time.current }
    solar_noon { Time.current }
    golden_hour { Time.current }
    day_length { Time.current }
  end
end

# Time.parse(value).strftime("%I:%M:%S %p")
