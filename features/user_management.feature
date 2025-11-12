Feature: User Management
  As a new user
  I want to register and create my profile
  So that I can start using the meal planning service

  Scenario: New user creates their profile
    Given I am on the dashboard page
    When I follow "Create User"
    Then I should see "Create New User"
    When I fill in the following:
      | Name         | Qianyi Fan  |
      | Height (cm)  | 172         |
      | Weight (kg)  | 60          |
      | Age          | 23          |
    And I select "Male" from "Sex"
    And I press "Create User"
    Then I should be on the dashboard page
    And I should see "Qianyi Fan"

  Scenario: User cannot create profile without required information
    Given I am on the new user page
    When I press "Create User"
    Then I should see "can't be blank"
    And I should see "Create New User"

