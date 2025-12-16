require 'rails_helper'

RSpec.describe ActualMealEntry, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:meal_plan) }
    it { is_expected.to belong_to(:food_item) }
  end

  describe 'validations' do
    it 'validates day_index, meal_type, grams and uniqueness' do
      expect(build(:actual_meal_entry, day_index: -1)).not_to be_valid
      expect(build(:actual_meal_entry, meal_type: 'invalid')).not_to be_valid
      expect(build(:actual_meal_entry, grams: 0)).not_to be_valid
      
      plan = create(:meal_plan)
      create(:actual_meal_entry, meal_plan: plan, day_index: 0, meal_type: 'breakfast')
      expect(build(:actual_meal_entry, meal_plan: plan, day_index: 0, meal_type: 'breakfast')).not_to be_valid
    end
  end

  describe '.for_day' do
    it 'returns entries for specific day' do
      plan = create(:meal_plan)
      entry = create(:actual_meal_entry, meal_plan: plan, day_index: 0)
      expect(ActualMealEntry.for_day(0)).to include(entry)
    end
  end
end
