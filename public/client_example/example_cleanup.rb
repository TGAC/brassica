require 'csv'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'

# A sample Ruby client which removes all data submitted to BIP using the bip_client_example.

if ARGV.size < 1
  STDERR.puts 'Not enough arguments. Usage:'
  STDERR.puts ' > ruby example_cleanup.rb api_key'
  exit 1
end

# @client = Net::HTTP.new('bip.earlham.ac.uk', 443)
@client = Net::HTTP.new('localhost', 3000)
@client.use_ssl = true
@client.verify_mode = OpenSSL::SSL::VERIFY_NONE
@headers = {
  'Content-Type' => 'application/json',
  'X-BIP-Api-Key' => ARGV[0]
}

def test_error(response)
  unless response['reason'].nil?
    STDERR.puts "Encountered the following BIP request error."
    STDERR.puts response['reason']
    exit 1
  end
end

def call_bip(request)
  response = @client.request(request)
  if response.body
    JSON.parse(response.body).tap{ |parsed| test_error(parsed) }
  else
    nil
  end
end

def pluralize_class(class_name)
  class_name == 'plant_variety' ? 'plant_varieties' : "#{class_name}s"
end


def delete_mine(plural_name)
  records_count = 0
  puts "Removing owned #{plural_name}"
  begin
    request = Net::HTTP::Get.new("/api/v1/#{plural_name}?only_mine=true", @headers)
    response = call_bip request
    records_count = response[plural_name].count
    if records_count > 0
      response[plural_name].each do |record|
        request = Net::HTTP::Delete.new("/api/v1/#{plural_name}/#{record['id']}", @headers)
        response = call_bip request
      end
    end
  end while records_count > 0
end

delete_mine('plant_varieties')
delete_mine('plant_lines')
delete_mine('plant_accessions')

# request = Net::HTTP::Get.new("/api/v1/plant_varieties?only_mine=true&plant_variety[query][plant_variety_name]=Dimension", @headers)
# response = call_bip request
# puts response
# puts '-----------------'
#
# request = Net::HTTP::Get.new("/api/v1/plant_varieties?only_mine=true", @headers)
# response = call_bip request
# puts response
# puts '-----------------'
#
# request = Net::HTTP::Get.new("/api/v1/plant_varieties?plant_variety[query][plant_variety_name]=Dimension", @headers)
# response = call_bip request
# puts response
# puts '-----------------'
#
# request = Net::HTTP::Get.new("/api/v1/plant_varieties?per_page=5", @headers)
# response = call_bip request
# puts response
# puts '-----------------'
