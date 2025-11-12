require 'rails_helper'

RSpec.describe DailyTracking, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:meal_plan) }
  end

  describe 'validations' do
    it 'validates day_index is integer >= 0' do
      tracking = build(:daily_tracking, day_index: -1)
      expect(tracking).not_to be_valid
    end

    it 'validates feedback presence' do
      tracking = build(:daily_tracking, feedback: nil)
      expect(tracking).not_to be_valid
    end

    it 'validates feedback inclusion' do
      tracking = build(:daily_tracking, feedback: 'invalid')
      expect(tracking).not_to be_valid
      
      DailyTracking::FEEDBACKS.each do |feedback|
        tracking = build(:daily_tracking, feedback: feedback)
        expect(tracking).to be_valid
      end
    end

    it 'validates uniqueness of day_index scoped to meal_plan' do
      plan = create(:meal_plan)
      create(:daily_tracking, meal_plan: plan, day_index: 0)
      
      duplicate = build(:daily_tracking, meal_plan: plan, day_index: 0)
      expect(duplicate).not_to be_valid
    end
  end
end

