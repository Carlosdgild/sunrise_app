# frozen_string_literal: true

# +LocationInformationSerializer+ Serializer
class LocationInformationSerializer < ActiveModel::Serializer
  attributes :id,
             :information_date,
             :sunrise,
             :sunset,
             :golden_hour

  def sunrise
    return if object.sunrise.blank?

    transform_time(object.sunrise)
  end

  def sunset
    return if object.sunset.blank?

    transform_time(object.sunset)
  end

  def golden_hour
    return if object.golden_hour.blank?

    transform_time(object.golden_hour)
  end

  def transform_time(value)
    value.strftime('%I:%M:%S %p')
  end
end
