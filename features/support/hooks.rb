# hooks.rb
Before do
  # This runs before each scenario
  DatabaseCleaner.start
end

After do
  # This runs after each scenario
  DatabaseCleaner.clean
end

