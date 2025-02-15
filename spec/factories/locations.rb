# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    name { Faker::Name.name }
    latitude { Faker::Number.decimal(l_digits: 3, r_digits: 8) }
    longitude { Faker::Number.decimal(l_digits: 3, r_digits: 8) }
  end
end
