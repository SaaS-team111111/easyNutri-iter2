require 'rails_helper'

RSpec.describe MealPlan, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:meal_entries).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:goal) }
    it { is_expected.to validate_presence_of(:duration_days) }
    it { is_expected.to validate_presence_of(:status) }
    
    it 'validates goal is in allowed list' do
      plan = build(:meal_plan, goal: 'Invalid Goal')
      expect(plan).not_to be_valid
      expect(plan.errors[:goal]).to be_present
    end

    it 'accepts valid goals' do
      MealPlan::GOALS.each do |goal|
        plan = build(:meal_plan, goal: goal)
        expect(plan).to be_valid
      end
    end
  end

  describe 'dependent destroy' do
    it 'removes entries when plan is deleted' do
      plan = create(:meal_plan, duration_days: 1, status: 'generated')
      create_list(:meal_entry, 3, meal_plan: plan)
      expect { plan.destroy }.to change(MealEntry, :count).by(-3)
    end
  end
end
