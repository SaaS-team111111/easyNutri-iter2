require 'rails_helper'

RSpec.describe MealPlan, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:meal_entries).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:goal) }
    it { is_expected.to validate_presence_of(:duration_days) }

    it 'validates goal is in allowed list' do
      expect(build(:meal_plan, goal: 'Invalid')).not_to be_valid
    end
  end

  describe 'core methods' do
    it '#completed? returns true when current_day >= duration_days' do
      expect(create(:meal_plan, duration_days: 7, current_day: 7).completed?).to be true
    end

    it '#meals_for_day returns entries for specific day' do
      plan = create(:meal_plan, duration_days: 3)
      entry = create(:meal_entry, meal_plan: plan, day_index: 0)
      expect(plan.meals_for_day(0)).to include(entry)
    end

    it '#goal_targets returns correct metric for each goal' do
      expect(create(:meal_plan, goal: 'Low Sodium').goal_targets[:metric]).to eq('sodium')
      expect(create(:meal_plan, goal: 'Weight Loss').goal_targets[:metric]).to eq('calories')
      expect(create(:meal_plan, goal: 'Muscle Gain').goal_targets[:metric]).to eq('protein')
    end
  end

  describe '#actual_nutrition_consumed' do
    let(:plan) { create(:meal_plan, duration_days: 3, current_day: 2) }
    let(:food) { create(:food_item, calories_per_100g: 200) }

    it 'calculates nutrition and uses actual entries when available' do
      create(:meal_entry, meal_plan: plan, food_item: food, day_index: 0, grams: 100, meal_type: 'breakfast')
      expect(plan.actual_nutrition_consumed[:calories]).to eq(200)
      
      actual_food = create(:food_item, calories_per_100g: 500)
      create(:actual_meal_entry, meal_plan: plan, food_item: actual_food, day_index: 0, grams: 100, meal_type: 'breakfast')
      expect(plan.actual_nutrition_consumed[:calories]).to eq(500)
    end
  end

  describe '#advance_day!' do
    let(:plan) { create(:meal_plan, duration_days: 3, current_day: 0, status: 'active') }

    it 'increments day and creates tracking' do
      expect { plan.advance_day!('strictly_followed') }
        .to change { plan.reload.current_day }.by(1)
        .and change { plan.daily_trackings.count }.by(1)
    end

    it 'returns false if completed and saves actual meals' do
      plan.update(current_day: 3)
      expect(plan.advance_day!('strictly_followed')).to be false
      
      plan.update(current_day: 0)
      food = create(:food_item)
      expect { plan.advance_day!('strictly_followed', { 'breakfast' => [{ food_item_id: food.id, grams: 100 }] }) }
        .to change { plan.actual_meal_entries.count }.by(1)
    end
  end

  describe '#goal_progress' do
    it 'calculates progress and handles zero days' do
      plan = create(:meal_plan, duration_days: 7, current_day: 0, goal: 'Weight Loss')
      expect { plan.goal_progress }.not_to raise_error
      
      plan.update(current_day: 3)
      food = create(:food_item, calories_per_100g: 200)
      create(:meal_entry, meal_plan: plan, food_item: food, day_index: 0, grams: 100)
      expect(plan.goal_progress[:calories][:current]).to be_a(Numeric)
    end
  end

  describe 'user_can_only_have_one_active_plan' do
    let(:user) { create(:user) }

    it 'prevents second active plan but allows when only completed exists' do
      create(:meal_plan, user: user, status: 'active')
      expect(build(:meal_plan, user: user, status: 'active')).not_to be_valid
      
      user.meal_plans.update_all(status: 'completed')
      expect(build(:meal_plan, user: user, status: 'active')).to be_valid
    end
  end

  describe '#today_actual_meals' do
    it 'returns actual meals for current day' do
      plan = create(:meal_plan, duration_days: 3, current_day: 1)
      actual = create(:actual_meal_entry, meal_plan: plan, day_index: 1, meal_type: 'lunch')
      expect(plan.today_actual_meals['lunch']).to include(actual)
    end
  end

  describe 'dependent destroy and Balanced Diet' do
    it 'removes entries when plan deleted and handles Balanced Diet progress' do
      plan = create(:meal_plan, duration_days: 1, status: 'generated', goal: 'Balanced Diet')
      create_list(:meal_entry, 3, meal_plan: plan)
      expect { plan.destroy }.to change(MealEntry, :count).by(-3)
      
      plan2 = create(:meal_plan, goal: 'Balanced Diet', current_day: 1)
      progress = plan2.goal_progress
      expect(progress).to have_key(:calories)
      expect(progress).to have_key(:protein)
    end
  end

  describe 'Algorithm: food selection and portion adjustment' do
    let(:plan) { create(:meal_plan, goal: 'Weight Loss', duration_days: 3, current_day: 1) }
    let!(:foods) do
      [
        create(:food_item, name: 'High Protein', protein_per_100g: 40, calories_per_100g: 300, sodium_mg_per_100g: 100),
        create(:food_item, name: 'Low Sodium', protein_per_100g: 15, calories_per_100g: 200, sodium_mg_per_100g: 10)
      ]
    end

    it 'selects foods based on goal' do
      plan.update(goal: 'Muscle Gain')
      result = plan.send(:select_foods_for_goal_based_on_history, foods, {}, 0, 0)
      expect(result.first.name).to eq('High Protein')

      plan.update(goal: 'Low Sodium')
      result = plan.send(:select_foods_for_goal_based_on_history, foods, {}, 0, 0)
      expect(result.first.name).to eq('Low Sodium')
    end

    it 'adjusts portions based on consumption' do
      allow(plan).to receive(:actual_nutrition_consumed).and_return({
        calories: 3600, protein: 0, carbs: 0, fat: 0, sodium: 0, days_tracked: 1
      })
      allow(plan).to receive(:rand).and_return(200)
      plan.send(:generate_day_recommendations, 1, foods)
      expect(plan.meal_recommendations.where(day_index: 1).pluck(:recommended_grams)).to all(be <= 200)
    end
  end
end
