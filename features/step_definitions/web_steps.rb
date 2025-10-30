require 'uri'
require 'cgi'

Given(/^I am on (.+)$/) do |page_name|
  visit path_to(page_name)
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
    fill_in(name, with: value)
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

