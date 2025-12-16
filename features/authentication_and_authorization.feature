Feature: Authentication and Authorization
  As this app user
  I want to register, login, and access my meal plans securely
  So that my data is protected and I can only access my own resources

  Background:
    Given there are multiple food items in the database

  Scenario: New user registers an account
    Given I am logged out
    And I am on the new account page
    When I fill in the following:
      | Username          | Qianyi Fan |
      | Password          | password123 |
      | Confirm Password  | password123 |
    And I press "Sign Up"
    Then I should be on the dashboard page
    And I should see "Account created successfully"

  Scenario: User cannot register with invalid information
    Given I am logged out
    And I am on the new account page
    When I fill in the following:
      | Username         | Qianyi Fan |
      | Password         | password123 |
      | Confirm Password | password456 |
    And I press "Sign Up"
    Then I should see "Password confirmation doesn't match Password"
    And I should see "Create Account"

  Scenario: User cannot register with duplicate username
    Given I am logged out
    And there is an account with username "Qianyi" and password "password123"
    And I am on the new account page
    When I fill in the following:
      | Username         | Qianyi |
      | Password         | password456 |
      | Confirm Password | password456 |
    And I press "Sign Up"
    Then I should see "Username has already been taken"
    And I should see "Create Account"

  Scenario: User logs in with valid credentials
    Given I am logged out
    And there is an account with username "Qianyi" and password "password123"
    And I am on the login page
    When I fill in "Username" with "Qianyi"
    And I fill in "Password" with "password123"
    And I press "Sign In"
    Then I should be on the dashboard page
    And I should see "Signed in successfully"

  Scenario: User cannot login with invalid credentials
    Given I am logged out
    And there is an account with username "Qianyi" and password "password123"
    And I am on the login page
    When I fill in "Username" with "Qianyi"
    And I fill in "Password" with "password456"
    And I press "Sign In"
    Then I should see "Invalid username or password"
    And I should be on the login page

  Scenario: User logs out
    Given I am logged in as "Qianyi" with password "password123"
    When I follow "Sign out"
    Then I should be on the login page
    And I should see "Signed out"
