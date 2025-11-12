require 'rails_helper'

RSpec.describe MealRecommendation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:meal_plan) }
    it { is_expected.to belong_to(:food_item) }
  end

  describe 'validations' do
    it 'validates day_index is integer >= 0' do
      rec = build(:meal_recommendation, day_index: -1)
      expect(rec).not_to be_valid
    end

    it 'validates meal_type inclusion' do
      rec = build(:meal_recommendation, meal_type: 'invalid')
      expect(rec).not_to be_valid
      
      %w[breakfast lunch dinner snack].each do |type|
        rec = build(:meal_recommendation, meal_type: type)
        expect(rec).to be_valid
      end
    end

    it 'validates recommended_grams is positive integer' do
      rec = build(:meal_recommendation, recommended_grams: 0)
      expect(rec).not_to be_valid
      
      rec = build(:meal_recommendation, recommended_grams: 100)
      expect(rec).to be_valid
    end
  end

  describe '.for_meal' do
    it 'returns recommendations for specific day and meal type' do
      plan = create(:meal_plan)
      rec1 = create(:meal_recommendation, meal_plan: plan, day_index: 0, meal_type: 'breakfast')
      rec2 = create(:meal_recommendation, meal_plan: plan, day_index: 0, meal_type: 'lunch')
      rec3 = create(:meal_recommendation, meal_plan: plan, day_index: 1, meal_type: 'breakfast')
      
      results = MealRecommendation.for_meal(0, 'breakfast')
      expect(results).to include(rec1)
      expect(results).not_to include(rec2, rec3)
    end
  end
end

