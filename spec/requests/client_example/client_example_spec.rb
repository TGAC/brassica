require 'rails_helper'

RSpec.describe "Client example script" do
  let(:user) { create :user }

  # before :all do
  #   # `rails server -d -e test`
  #   # `bundle exec thin -e test start --ssl`
  # end

  # after :all do
  #   pid = File.read('tmp/pids/server.pid')
  #   `kill -9 #{pid}`
  # end

  before :each do
    # host! "localhost"
    https! true
    # port! 3000
    # @request.env['HTTPS'] = 'on'
    # @request.host = "localhost"
    # @request.port = 3000
  end

  it 'registers data in BIP' do
    get "/"

    sleep 10
    # request.env['HTTPS'] = 'on'
    # ENV['SERVER_NAME'] = "user.myapp.com"
    `ruby public/client_example/bip_client_example.rb public/client_example/tocopherols.csv #{user.api_key.token}`
  end
end


# Class Server
# def initialize(server_path)
#   @server_path = server_path
# end
#
# def start
#   `#{rails_script} server -d -e test`
# end
#
# def stop
#   pid = File.read(pidfile)
#   `kill -9 #{pid}`
# end
#
# private
#
# def rails_script
#   File.join(@server_path, 'script', 'rails')
# end
#
# def pidfile
#   File.join(@server_path, 'tmp', 'pids', 'server.pid')
# end
# end
