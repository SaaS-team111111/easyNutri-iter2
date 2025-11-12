Feature: Comprehensive Meal Plan Testing
  As a quality assurance engineer
  I want to ensure all meal plan functionality is properly tested
  So that the application works as expected

  Background:
    Given there is a user named "Zhengda" in the database
    And there are multiple food items in the database

  Scenario: Test with actual meals for Balanced Diet
    Given there is a "Balanced Diet" meal plan for "Zhengda", lasting 7 days
    And the meal plan has 1 days completed with "strictly_followed" feedback
    And the meal plan has actual meals eaten for day 2 with:
      | Meal Type | Food | Grams |
      | breakfast | Chicken Breast | 200 |
      | lunch | Rice | 300 |
    Then the actual nutrition consumed should reflect the eaten meals
    And the goal progress should show non-zero values

  Scenario: Test recommended nutrition and meal plan viewing
    Given there is a "Weight Loss" meal plan for "Zhengda", lasting 5 days
    Then the recommended nutrition should contain values for all nutrients
