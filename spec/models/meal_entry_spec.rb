require 'rails_helper'

RSpec.describe MealEntry, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:meal_plan) }
    it { is_expected.to belong_to(:food_item) }
  end

  describe 'validations' do
    it 'validates meal_type inclusion' do
      entry = build(:meal_entry, meal_type: 'invalid')
      expect(entry).not_to be_valid
      expect(entry.errors[:meal_type]).to be_present
    end

    it 'accepts valid meal_types' do
      %w[breakfast lunch dinner snack].each do |meal_type|
        entry = build(:meal_entry, meal_type: meal_type)
        expect(entry).to be_valid
      end
    end
  end
end
