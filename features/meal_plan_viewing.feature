Feature: Viewing Meal Plans
  As a user with a meal plan
  I want to view my detailed meal schedule
  So that I know what to eat each day

  Background:
    Given there is a user named "Zian" in the database
    And there is a "Weight Loss" meal plan for "Zian", lasting 7 days
    And there are multiple food items in the database

  Scenario: User views the dashboard to see available meal plans
    When I am on the dashboard page
    Then I should see "Easy-Nutri Dashboard"
    And I should see "View User's Meal Plans"

  Scenario: User views their meal plan details
    When I view the meal plan for "Zian"
    Then I should see "Meal Plan for Zian"
    And I should see "Weight Loss"
    And I should see "7 days"
    And I should see "Goal:"
    And I should see "Duration:"
