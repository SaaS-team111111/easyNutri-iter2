require 'rails_helper'

RSpec.describe DailyTracking, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:meal_plan) }
  end

  describe 'validations' do
    it 'validates day_index, feedback and uniqueness' do
      expect(build(:daily_tracking, day_index: -1)).not_to be_valid
      expect(build(:daily_tracking, feedback: nil)).not_to be_valid
      expect(build(:daily_tracking, feedback: 'invalid')).not_to be_valid
      
      plan = create(:meal_plan)
      create(:daily_tracking, meal_plan: plan, day_index: 0)
      expect(build(:daily_tracking, meal_plan: plan, day_index: 0)).not_to be_valid
    end
  end
end
