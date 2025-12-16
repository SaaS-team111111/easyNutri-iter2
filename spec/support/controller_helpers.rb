module ControllerHelpers
  def login_account(account = nil)
    account ||= create(:account)
    session[:account_id] = account.id
    account
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers, type: :controller
end

