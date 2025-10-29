require "test_helper"

class MealPlansControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get meal_plans_new_url
    assert_response :success
  end

  test "should get create" do
    get meal_plans_create_url
    assert_response :success
  end

  test "should get show" do
    get meal_plans_show_url
    assert_response :success
  end
end
