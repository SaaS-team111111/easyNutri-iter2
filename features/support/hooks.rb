Before do
  DatabaseCleaner.start
  @test_account = Account.create!(
    username: "cucumber_test",
    password: "password123",
    password_confirmation: "password123"
  )
  visit "/login"
  fill_in "Username", with: "cucumber_test"
  fill_in "Password", with: "password123"
  click_button "Sign In"
end

After do
  DatabaseCleaner.clean
end
