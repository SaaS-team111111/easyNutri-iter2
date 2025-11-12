Feature: Viewing Meal Plans
  As a user with a meal plan
  I want to view my detailed meal schedule
  So that I know what to eat each day

  Scenario: User views their meal plan details
    Given there is a user named "Qianyi" in the database
    And there is a food item named "Chicken Breast" with 165 calories
    And there is a "Weight Loss" meal plan for "Qianyi", lasting 7 days
    When I view the meal plan for "Qianyi"
    Then I should see "Meal Plan for Qianyi"
    And I should see "Weight Loss"
    And I should see "7 days"
    And I should see "Goal:"
    And I should see "Duration:"

  Scenario: User views the dashboard to see available meal plans
    Given there is a user named "Zian" in the database
    And there is a "Muscle Gain" meal plan for "Zian", lasting 14 days
    When I am on the dashboard page
    Then I should see "Easy-Nutri Dashboard"
    And I should see "View User's Meal Plans"


