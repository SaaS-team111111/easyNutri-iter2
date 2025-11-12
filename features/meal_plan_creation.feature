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
    Then I should be on the dashboard page
    And I should see "Qianyi"
    And I should see "<goal>"
    And I should see "Today's Recommended Menu"

    Examples:
      | goal          | duration |
      | Weight Loss   | 7        |
      | Muscle Gain   | 14       |
      | Low Sodium    | 7        |
      | Balanced Diet | 10       |

  Scenario: User with active meal plan sees replace modal when creating new plan
    Given there is a "Weight Loss" meal plan for "Qianyi", lasting 5 days
    And I am on the new meal plan page
    When I select "Qianyi" from "Select User"
    And I select "Muscle Gain" from "Goal"
    And I fill in "Duration (days)" with "10"
    And I press "Generate Plan"
    Then I should see the replace existing meal plan modal


