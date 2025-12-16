require 'rails_helper'

RSpec.describe MealEntry, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:meal_plan) }
    it { is_expected.to belong_to(:food_item) }
  end

  describe 'validations' do
    it 'validates meal_type inclusion' do
      expect(build(:meal_entry, meal_type: 'invalid')).not_to be_valid
      %w[breakfast lunch dinner snack].each do |type|
        expect(build(:meal_entry, meal_type: type)).to be_valid
      end
    end
  end
end
