# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'shoulda/matchers'
require 'factory_girl_rails'
require 'common_helpers'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir.mkdir(Rails.root.join("tmp")) unless Dir.exists?(Rails.root.join("tmp"))
Dir.mkdir(Rails.root.join("tmp/cache")) unless Dir.exists?(Rails.root.join("tmp/cache"))

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

Rails.application.eager_load!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include FactoryGirl::Syntax::Methods
  config.include Warden::Test::Helpers, type: :request
  config.include Warden::Test::Helpers, type: :controller
  config.include Devise::TestHelpers, type: :controller
  config.include RSpecHtmlMatchers
  include CommonHelpers

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
  end

  config.around :each do |example|
    DatabaseCleaner.strategy = example.metadata[:elasticsearch] ? :truncation : :transaction
    DatabaseCleaner.start unless example.metadata[:dont_clean_db]
    example.run
    DatabaseCleaner.clean unless example.metadata[:dont_clean_db]
  end

  config.before :each do |example|
    unless example.metadata[:elasticsearch]
      es = Class.new do
        def index_document; end
        def update_document; end
        def delete_document; end
      end.new

      searchable_models.each do |model|
        allow_any_instance_of(model).to receive(:__elasticsearch__).and_return(es)
      end
    end
  end

  config.before :all, :elasticsearch do |example|
    WebMock.disable_net_connect!(allow_localhost: true)
    searchable_models.each do |model|
      model.import force: true, refresh: true
    end
  end

  config.after :suite do
    FileUtils.rm_rf(Dir["#{Rails.root}/spec/uploads/"])
  end
end

OmniAuth.config.test_mode = true
