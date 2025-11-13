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

  Scenario: User edits their profile information
    Given there is a user named "Alice" in the database
    And I am on the dashboard page
    When I select "Alice" from user selector
    And I follow "Manage User"
    Then I should see "Edit User"
    When I fill in the following:
      | Name         | Alice Smith  |
      | Height (cm)  | 165          |
      | Weight (kg)  | 55           |
      | Age          | 28           |
    And I select "Female" from "Sex"
    And I press "Update User"
    Then I should be on the dashboard page
    And I should see "User updated successfully"
    And I should see "Alice Smith"

  Scenario: User deletes their profile
    Given there is a user named "Bob" in the database
    And I am on the dashboard page
    When I select "Bob" from user selector
    And I follow "Manage User"
    Then I should see "Edit User"
    When I click "Delete User" and confirm deletion
    Then I should be on the dashboard page
    And I should see "User deleted successfully"
    And I should not see "Bob"

