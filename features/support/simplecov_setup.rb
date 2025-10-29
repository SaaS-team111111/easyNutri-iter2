require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/app/channels/'
  add_filter '/app/jobs/'
  add_filter '/app/mailers/'
end
puts "SimpleCov started: Coverage results will be in coverage/ directory."


