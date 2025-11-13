Feature: Meal plan update with Dynamic Recommendations
  As a user
  I want to advance through my meal plan with my feedback input
  So that my recommendations adapt to my eating patterns

  Background:
    Given there is a user named "Zhengda" in the database
    And there are multiple food items in the database
    And there is a "Weight Loss" meal plan for "Zhengda", lasting 3 days

  Scenario: Advance day with strictly_followed feedback
    Given I navigate to advance the meal plan
    When I submit feedback "strictly_followed"
    Then the meal plan should advance to day 1
    And the status should be "active"

  Scenario: Advance day with more_healthy feedback
    Given the meal plan has 0 days completed with "strictly_followed" feedback
    And I navigate to advance the meal plan
    When I submit feedback "more_healthy"
    Then the meal plan should advance to day 1
    And a daily tracking entry should be created with "more_healthy"

  Scenario: Advance day with actual meals for Muscle Gain with user manual records
    Given I navigate to advance the meal plan with actual meals for day 1:
      | Meal Type | Food           | Grams |
      | breakfast | Salmon         | 200   |
      | lunch     | Chicken Breast | 300   |
      | dinner    | Salmon         | 200   |
    When I submit feedback "strictly_followed"
    Then the meal plan should advance to day 1
    And actual meals should be recorded for day 1

  Scenario: User can see the total nutrition sum-up
    Given the meal plan has 1 days completed with "strictly_followed" feedback
    And the meal plan has actual meals eaten for day 2 with:
      | Meal Type | Food           | Grams |
      | breakfast | Chicken Breast | 200   |
      | lunch     | Rice           | 300   |
    Then the actual nutrition consumed should reflect the eaten meals
    And the goal progress should show non-zero values

  Scenario: User advances to the last day and completes the meal plan
    Given the meal plan has 2 days completed with "strictly_followed" feedback
    And I navigate to advance the meal plan
    When I submit feedback "strictly_followed"
    Then the meal plan should advance to day 3
    And the meal plan should be marked as completed
    And I should be redirected with just_completed flag
