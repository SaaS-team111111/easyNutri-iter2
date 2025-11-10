class CreateDailyTrackings < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_trackings do |t|
      t.references :meal_plan, null: false, foreign_key: true
      t.integer :day_index, null: false
      t.string :feedback, null: false
      
      t.timestamps
    end
    
    add_index :daily_trackings, [:meal_plan_id, :day_index], unique: true
  end
end


