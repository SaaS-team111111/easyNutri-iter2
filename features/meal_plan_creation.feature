Feature: Meal Plan Creation
  As a registered user
  I want to create personalized meal plans
  So that I can achieve my health and nutrition goals

  Background:
    Given there is a user named "Qianyi" in the database
    And there are multiple food items in the database

  Scenario Outline: User creates a personalized meal plan for different health goals
    Given I am on the new meal plan page
    When I select "Qianyi" from "Select User"
    And I select "<goal>" from "Goal"
    And I fill in "Duration (days)" with "<duration>"
    And I press "Generate Plan"
    Then I should see "Meal Plan for Qianyi"
    And I should see "<goal>"
    And I should see "<duration> days"
    And I should see "Detailed Meal Schedule"

    Examples:
      | goal          | duration |
      | Weight Loss   | 7        |
      | Muscle Gain   | 14       |
      | Low Sodium    | 7        |
      | Balanced Diet | 10       |

