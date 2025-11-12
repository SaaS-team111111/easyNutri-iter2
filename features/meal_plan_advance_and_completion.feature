Feature: Meal Plan Advance Day and Completion
  As a user
  I want to advance through my meal plan with feedback
  So that my recommendations adapt to my eating patterns

  Background:
    Given there is a user named "Zhengda" in the database
    And there are multiple food items in the database

  Scenario: Advance day with strictly_followed feedback
    Given there is a "Weight Loss" meal plan for "Zhengda", lasting 5 days
    And I navigate to advance the meal plan
    When I submit feedback "strictly_followed"
    Then the meal plan should advance to day 1
    And the status should be "active"

  Scenario: Advance day with more_healthy feedback
    Given there is a "Low Sodium" meal plan for "Zhengda", lasting 5 days
    And the meal plan has 0 days completed with "strictly_followed" feedback
    And I navigate to advance the meal plan
    When I submit feedback "more_healthy"
    Then the meal plan should advance to day 1
    And a daily tracking entry should be created with "more_healthy"

  Scenario: Advance day with actual meals for Muscle Gain
    Given there is a "Muscle Gain" meal plan for "Zhengda", lasting 7 days
    And I navigate to advance the meal plan with actual meals for day 1:
      | Meal Type | Food | Grams |
      | breakfast | Salmon | 200 |
      | lunch | Chicken Breast | 300 |
      | dinner | Salmon | 200 |
    When I submit feedback "strictly_followed"
    Then the meal plan should advance to day 1
    And actual meals should be recorded for day 1