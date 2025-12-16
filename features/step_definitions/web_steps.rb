require 'uri'
require 'cgi'

Given(/^I am on (.+)$/) do |page_name|
  case page_name
  when /^the new account page$/
    visit new_account_path
  when /^the login page$/
    visit login_path
  else
    visit path_to(page_name)
  end
end

When(/^I go to (.+)$/) do |page_name|
  visit path_to(page_name)
end

When(/^I press "([^"]*)"$/) do |button|
  click_button(button)
end

When(/^I follow "([^"]*)"$/) do |link|
  click_link(link)
end

When(/^I fill in "([^"]*)" with "([^"]*)"$/) do |field, value|
  fill_in(field, with: value)
end

When(/^I fill in the following:$/) do |fields|
  fields.rows_hash.each do |name, value|
    field_map = {
      "Username" => "Username",
      "Password" => "Password",
      "Confirm Password" => "Confirm Password",
      "Password confirmation" => "Confirm Password"
    }
    
    field_identifier = field_map[name] || name
    
    begin
      fill_in(field_identifier, with: value)
    rescue Capybara::ElementNotFound
      case field_identifier.downcase
      when /confirm|confirmation/
        fill_in("account[password_confirmation]", with: value)
      when "username"
        fill_in("account[username]", with: value)
      when "password"
        fill_in("account[password]", with: value)
      else
        raise Capybara::ElementNotFound, "Could not find field '#{name}' or '#{field_identifier}'"
      end
    end
  end
end

When(/^I select "([^"]*)" from "([^"]*)"$/) do |value, field|
  select(value, from: field)
end

When(/^I check "([^"]*)"$/) do |field|
  check(field)
end

When(/^I uncheck "([^"]*)"$/) do |field|
  uncheck(field)
end

When(/^I choose "([^"]*)"$/) do |field|
  choose(field)
end

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^I should not see "([^"]*)"$/) do |text|
  expect(page).not_to have_content(text)
end

Then(/^I should see \/([^\/]*)\/$/

) do |regexp|
  regexp = Regexp.new(regexp)
  expect(page).to have_xpath('//*', text: regexp)
end

Then(/^the "([^"]*)" field should contain "([^"]*)"$/) do |field, value|
  field_element = find_field(field)
  field_value = (field_element.tag_name == 'textarea') ? field_element.text : field_element.value
  expect(field_value).to match(/#{value}/)
end

Then(/^the "([^"]*)" checkbox should be checked$/) do |label|
  field_checked = find_field(label)['checked']
  expect(field_checked).to be_truthy
end

Then(/^the "([^"]*)" checkbox should not be checked$/) do |label|
  field_checked = find_field(label)['checked']
  expect(field_checked).to be_falsey
end

Then(/^I should be on (.+)$/) do |page_name|
  current_path = URI.parse(current_url).path
  expect(current_path).to eq(path_to(page_name))
end

Then(/^show me the page$/) do
  save_and_open_page
end

