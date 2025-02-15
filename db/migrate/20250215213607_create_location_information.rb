class CreateLocationInformation < ActiveRecord::Migration[8.0]
  def change
    create_table :location_informations do |t|
      t.references :location, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.time :sunrise
      t.time :sunset
      t.time :first_light
      t.time :last_light
      t.time :dawn
      t.time :dusk
      t.time :solar_noon
      t.time :golden_hour
      t.time :day_length
      t.timestamps
    end
     add_index :location_informations, %i[location_id start_date end_date],
               unique: true, name: 'location_and_dates_index'
  end
end
