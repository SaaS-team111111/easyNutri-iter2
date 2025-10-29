class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :height_cm
      t.integer :weight_kg
      t.integer :age
      t.string :sex

      t.timestamps
    end
  end
end
