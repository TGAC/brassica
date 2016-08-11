require 'csv'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'

# A sample Ruby client which removes all PV, PL, PA and PP data
# related to a single PP submitted to BIP using a certain API KEY.

if ARGV.size < 2
  STDERR.puts 'Not enough arguments. Usage:'
  STDERR.puts ' > ruby population_cleanup.rb plant_population_name api_key'
  exit 1
end

# @client = Net::HTTP.new('bip.earlham.ac.uk', 443)
@client = Net::HTTP.new('localhost', 3000)
@client.use_ssl = true
@client.verify_mode = OpenSSL::SSL::VERIFY_NONE
@headers = {
  'Content-Type' => 'application/json',
  'X-BIP-Api-Key' => ARGV[1]
}

def test_error(response, request)
  unless response['reason'].nil?
    STDERR.puts "Encountered the following BIP request error."
    STDERR.puts response['reason']
    if response['reason'] == 'This resource is already published and irrevocable'
      @untouchables << request.path.split('/').last.to_i
    else
      STDERR.puts "Exiting."
      exit 1
    end
  end
end

def call_bip(request)
  response = @client.request(request)
  if response.body
    JSON.parse(response.body).tap{ |parsed| test_error(parsed, request) }
  else
    nil
  end
end

def pluralize_class(class_name)
  class_name == 'plant_variety' ? 'plant_varieties' : "#{class_name}s"
end


def delete_mine(plural_name, query = '')
  @untouchables = []
  records_count = 0
  puts "Removing owned #{plural_name}"
  begin
    request = Net::HTTP::Get.new("/api/v1/#{plural_name}?only_mine=true#{query}", @headers)
    response = call_bip request
    records_count = response[plural_name].count
    if records_count > 0 && records_count > @untouchables.size
      response[plural_name].each do |record|
        request = Net::HTTP::Delete.new("/api/v1/#{plural_name}/#{record['id']}", @headers)
        response = call_bip request
      end
    end
  end while records_count > 0 && records_count > @untouchables.size
end


# Step 1. Searching for the population id.

request = Net::HTTP::Get.new("/api/v1/plant_populations?only_mine=true&plant_population[query][name]=#{URI.escape ARGV[0]}", @headers)
response = call_bip request

if response['plant_populations'].count == 0
  STDERR.puts "Plant Population #{ARGV[0]} not found or it does not belong to you. Exiting."
  exit 1
end

plant_population_id = response['plant_populations'][0]['id']

puts "Found the Plant Population, id = #{plant_population_id}."

# Step 2. Searching for owned Plant Lines related to this population
puts "Removing owned Plant Lines related to this population."
delete_mine('plant_lines', "&plant_line[query][plant_populations.id]=#{plant_population_id}")
