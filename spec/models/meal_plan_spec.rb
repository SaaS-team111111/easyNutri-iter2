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

  describe '#completed?' do
    it 'returns false when current_day < duration_days' do
      plan = create(:meal_plan, duration_days: 7, current_day: 3)
      expect(plan.completed?).to be false
    end

    it 'returns true when current_day >= duration_days' do
      plan = create(:meal_plan, duration_days: 7, current_day: 7)
      expect(plan.completed?).to be true
    end
  end

  describe '#meals_for_day' do
    it 'returns meals for specific day' do
      plan = create(:meal_plan, duration_days: 3)
      entry1 = create(:meal_entry, meal_plan: plan, day_index: 0, meal_type: 'breakfast')
      entry2 = create(:meal_entry, meal_plan: plan, day_index: 0, meal_type: 'lunch')
      entry3 = create(:meal_entry, meal_plan: plan, day_index: 1, meal_type: 'breakfast')
      
      meals = plan.meals_for_day(0)
      expect(meals).to include(entry1, entry2)
      expect(meals).not_to include(entry3)
    end
  end

  describe '#today_meals' do
    it 'returns meals for current day' do
      plan = create(:meal_plan, duration_days: 3, current_day: 1)
      entry1 = create(:meal_entry, meal_plan: plan, day_index: 0)
      entry2 = create(:meal_entry, meal_plan: plan, day_index: 1)
      
      expect(plan.today_meals).to include(entry2)
      expect(plan.today_meals).not_to include(entry1)
    end
  end

  describe '#goal_targets' do
    it 'returns correct targets for Low Sodium' do
      plan = create(:meal_plan, goal: 'Low Sodium')
      targets = plan.goal_targets
      expect(targets[:metric]).to eq('sodium')
      expect(targets[:target_per_day]).to eq(1500)
      expect(targets[:unit]).to eq('mg')
    end

    it 'returns correct targets for Weight Loss' do
      plan = create(:meal_plan, goal: 'Weight Loss')
      targets = plan.goal_targets
      expect(targets[:metric]).to eq('calories')
      expect(targets[:target_per_day]).to eq(1800)
      expect(targets[:unit]).to eq('kcal')
    end

    it 'returns correct targets for Muscle Gain' do
      plan = create(:meal_plan, goal: 'Muscle Gain')
      targets = plan.goal_targets
      expect(targets[:metric]).to eq('protein')
      expect(targets[:target_per_day]).to eq(150)
      expect(targets[:unit]).to eq('g')
    end

    it 'returns correct targets for Balanced Diet' do
      plan = create(:meal_plan, goal: 'Balanced Diet')
      targets = plan.goal_targets
      expect(targets[:metric]).to eq('balanced')
      expect(targets[:targets]).to be_a(Hash)
      expect(targets[:targets][:calories][:target_per_day]).to eq(2000)
    end
  end

  describe '#actual_nutrition_consumed' do
    let(:plan) { create(:meal_plan, duration_days: 3, current_day: 2) }
    let(:food) { create(:food_item, calories_per_100g: 200, protein_per_100g: 20) }

    it 'returns zero nutrition when no meals consumed but tracks days' do
      consumed = plan.actual_nutrition_consumed
      expect(consumed[:calories]).to eq(0)
      expect(consumed[:protein]).to eq(0)
      expect(consumed[:days_tracked]).to eq(2) # current_day = 2, so 2 days have passed
    end

    it 'calculates nutrition from meal entries when no actual entries' do
      create(:meal_entry, meal_plan: plan, food_item: food, day_index: 0, grams: 100)
      create(:meal_entry, meal_plan: plan, food_item: food, day_index: 1, grams: 150)
      
      consumed = plan.actual_nutrition_consumed
      expect(consumed[:calories]).to eq(500) # 200 + 300
      expect(consumed[:protein]).to eq(50) # 20 + 30
      expect(consumed[:days_tracked]).to eq(2)
    end
  end

  describe '#advance_day!' do
    let(:plan) { create(:meal_plan, duration_days: 3, current_day: 0, status: 'active') }

    it 'increments current_day' do
      expect { plan.advance_day!('strictly_followed') }
        .to change { plan.reload.current_day }.from(0).to(1)
    end

    it 'creates daily tracking entry' do
      expect { plan.advance_day!('strictly_followed') }
        .to change { plan.daily_trackings.count }.by(1)
    end

    it 'returns false if plan is completed' do
      plan.update(current_day: 3)
      expect(plan.advance_day!('strictly_followed')).to be false
    end

    it 'saves actual meals when provided' do
      food = create(:food_item)
      actual_meals = {
        'breakfast' => { food_item_id: food.id, grams: 100 }
      }
      
      expect { plan.advance_day!('strictly_followed', actual_meals) }
        .to change { plan.actual_meal_entries.count }.by(1)
    end

    it 'skips actual meals with missing data' do
      food = create(:food_item)
      actual_meals = {
        'breakfast' => { food_item_id: food.id, grams: nil },
        'lunch' => { food_item_id: nil, grams: 100 }
      }
      
      expect { plan.advance_day!('strictly_followed', actual_meals) }
        .not_to change { plan.actual_meal_entries.count }
    end
  end

  describe '#goal_progress' do
    let(:plan) { create(:meal_plan, duration_days: 7, current_day: 3, goal: 'Weight Loss') }
    let(:food) { create(:food_item, calories_per_100g: 200, protein_per_100g: 20) }

    before do
      create(:meal_entry, meal_plan: plan, food_item: food, day_index: 0, grams: 100)
      create(:meal_entry, meal_plan: plan, food_item: food, day_index: 1, grams: 150)
    end

    it 'calculates progress for single metric goals' do
      progress = plan.goal_progress
      expect(progress).to have_key(:calories)
      expect(progress[:calories][:current]).to be_a(Numeric)
      expect(progress[:calories][:target]).to be_a(Numeric)
      expect(progress[:calories][:percentage]).to be_a(Numeric)
    end

    it 'calculates progress for Balanced Diet goal' do
      plan.update(goal: 'Balanced Diet')
      progress = plan.goal_progress
      
      expect(progress).to have_key(:calories)
      expect(progress).to have_key(:protein)
      expect(progress).to have_key(:carbs)
      expect(progress).to have_key(:fat)
    end

    it 'handles zero days tracked without division error' do
      plan.update(current_day: 0)
      expect { plan.goal_progress }.not_to raise_error
    end
  end

  describe '#recommended_nutrition' do
    let(:plan) { create(:meal_plan, duration_days: 3) }
    let(:food) { create(:food_item, calories_per_100g: 300, protein_per_100g: 25) }

    it 'calculates total recommended nutrition from meal entries' do
      create(:meal_entry, meal_plan: plan, food_item: food, day_index: 0, grams: 100)
      create(:meal_entry, meal_plan: plan, food_item: food, day_index: 1, grams: 200)
      
      recommended = plan.recommended_nutrition
      expect(recommended[:calories]).to eq(900) # 300 + 600
      expect(recommended[:protein]).to eq(75.0) # 25 + 50
    end

    it 'returns zero when no meal entries exist' do
      recommended = plan.recommended_nutrition
      expect(recommended[:calories]).to eq(0)
      expect(recommended[:protein]).to eq(0)
    end
  end

  describe '#today_recommendations' do
    let(:plan) { create(:meal_plan, duration_days: 3, current_day: 1) }

    it 'returns recommendations for current day grouped by meal type' do
      rec1 = create(:meal_recommendation, meal_plan: plan, day_index: 1, meal_type: 'breakfast')
      rec2 = create(:meal_recommendation, meal_plan: plan, day_index: 1, meal_type: 'breakfast')
      rec3 = create(:meal_recommendation, meal_plan: plan, day_index: 0, meal_type: 'lunch')
      
      recommendations = plan.today_recommendations
      expect(recommendations).to be_a(Hash)
      expect(recommendations['breakfast']).to include(rec1, rec2)
      expect(recommendations['breakfast']).not_to include(rec3)
    end
  end

  describe '#today_actual_meals' do
    let(:plan) { create(:meal_plan, duration_days: 3, current_day: 1) }

    it 'returns actual meals for current day grouped by meal type' do
      actual1 = create(:actual_meal_entry, meal_plan: plan, day_index: 1, meal_type: 'lunch')
      actual2 = create(:actual_meal_entry, meal_plan: plan, day_index: 0, meal_type: 'dinner')
      
      actual_meals = plan.today_actual_meals
      expect(actual_meals).to be_a(Hash)
      expect(actual_meals['lunch']).to include(actual1)
      expect(actual_meals['lunch']).not_to include(actual2)
    end
  end

  describe 'validation: user_can_only_have_one_active_plan' do
    let(:user) { create(:user) }

    it 'prevents creating second active plan for same user' do
      create(:meal_plan, user: user, status: 'active')
      
      second_plan = build(:meal_plan, user: user, status: 'active')
      expect(second_plan).not_to be_valid
      expect(second_plan.errors[:base]).to include('User already has an active meal plan')
    end

    it 'allows creating multiple non-active plans' do
      create(:meal_plan, user: user, status: 'completed')
      
      second_plan = build(:meal_plan, user: user, status: 'completed')
      expect(second_plan).to be_valid
    end

    it 'allows creating active plan when user has no active plans' do
      create(:meal_plan, user: user, status: 'completed')
      
      active_plan = build(:meal_plan, user: user, status: 'active')
      expect(active_plan).to be_valid
    end
  end
end
