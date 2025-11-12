require 'rails_helper'

RSpec.describe ActualMealEntry, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:meal_plan) }
    it { is_expected.to belong_to(:food_item) }
  end

  describe 'validations' do
    it 'validates day_index is integer >= 0' do
      entry = build(:actual_meal_entry, day_index: -1)
      expect(entry).not_to be_valid
    end

    it 'validates meal_type inclusion' do
      entry = build(:actual_meal_entry, meal_type: 'invalid')
      expect(entry).not_to be_valid
      
      %w[breakfast lunch dinner snack].each do |type|
        entry = build(:actual_meal_entry, meal_type: type)
        expect(entry).to be_valid
      end
    end

    it 'validates grams is positive integer' do
      entry = build(:actual_meal_entry, grams: 0)
      expect(entry).not_to be_valid
      
      entry = build(:actual_meal_entry, grams: 100)
      expect(entry).to be_valid
    end

    it 'validates uniqueness of day_index scoped to meal_plan and meal_type' do
      plan = create(:meal_plan)
      create(:actual_meal_entry, meal_plan: plan, day_index: 0, meal_type: 'breakfast')
      
      duplicate = build(:actual_meal_entry, meal_plan: plan, day_index: 0, meal_type: 'breakfast')
      expect(duplicate).not_to be_valid
    end
  end

  describe '.for_day' do
    it 'returns entries for specific day' do
      plan = create(:meal_plan)
      entry1 = create(:actual_meal_entry, meal_plan: plan, day_index: 0)
      entry2 = create(:actual_meal_entry, meal_plan: plan, day_index: 1, meal_type: 'lunch')
      
      expect(ActualMealEntry.for_day(0)).to include(entry1)
      expect(ActualMealEntry.for_day(0)).not_to include(entry2)
    end
  end
end

