class CreateLocation < ActiveRecord::Migration[8.0]
  def change
    create_table :locations do |t|
      t.string :name, null: false
      t.decimal :latitude, null: false
      t.decimal :longitude, null: false
      t.timestamps
    end
    add_index :locations, :name, unique: true
  end
end
