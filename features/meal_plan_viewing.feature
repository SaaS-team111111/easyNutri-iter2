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
    Then I should see "Dashboard"
    And I should see "Select a User to Get Started"

  Scenario: User views their meal plan details
    When I view the meal plan for "Zian"
    Then I should see "Meal Plan for Zian"
    And I should see "Weight Loss"
    And I should see "7 days"
    And I should see "Goal:"
    And I should see "Duration:"

  Scenario: User without meal plan views dashboard
    Given there is a user named "NewUser" in the database
    And there are multiple food items in the database
    When I visit the dashboard for user "NewUser"
    Then I should see "Dashboard"
    And I should see "NewUser"

  Scenario: User views dashboard with just completed meal plan
    Given there is a user named "CompletedUser" in the database
    And there are multiple food items in the database
    And there is a "Weight Loss" meal plan for "CompletedUser", lasting 3 days
    And the meal plan has 2 days completed with "strictly_followed" feedback
    When I visit the dashboard with "CompletedUser" selected and just_completed flag
    Then I should see "Dashboard"
