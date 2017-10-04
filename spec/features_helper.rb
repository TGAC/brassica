require "rails_helper"

require 'capybara'
require 'capybara/poltergeist'
require 'launchy'

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, inspector: true)
end

Capybara.javascript_driver = :poltergeist #_debug
Capybara.default_max_wait_time = 10
Capybara.asset_host = 'http://localhost:3000'

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature
  config.include Features::SessionHelpers, type: :feature
  config.include Features::CommonHelpers, type: :feature

  config.before(:all, type: :feature) { Warden.test_mode! }
  config.after(:each, type: :feature) { Warden.test_reset! }

  config.after(:each, type: :feature) do
    Capybara.reset_sessions!
    page.driver.reset!

    # Prevents issues with mixing trancation and truncation/deletion cleaning strategies
    ActiveRecord::Base.connection_pool.disconnect!
  end
end
