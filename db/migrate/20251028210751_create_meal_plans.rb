class CreateMealPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :meal_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :goal
      t.integer :duration_days
      t.string :status

      t.timestamps
    end
  end
end
