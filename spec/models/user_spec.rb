require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'associations & validations' do
    it { is_expected.to have_many(:meal_plans).dependent(:destroy) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
