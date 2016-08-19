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

@client = Net::HTTP.new('bip.earlham.ac.uk', 443)
@client.use_ssl = true
@client.verify_mode = OpenSSL::SSL::VERIFY_NONE
@headers = {
  'Content-Type' => 'application/json',
  'X-BIP-Api-Key' => ARGV[1]
}

def test_error(response)
  unless response['reason'].nil?
    STDERR.puts "Encountered the following BIP request error."
    STDERR.puts response['reason']
    STDERR.puts "Exiting."
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

# Tries to delete a record
# Reports an error if it is impossible, yet does not stop the script execution
def delete_record(plural_name, id)
  request = Net::HTTP::Delete.new("/api/v1/#{plural_name}/#{id}", @headers)
  response = @client.request(request)
  unless response['reason'].nil?
    STDERR.puts "Encountered the following BIP request error."
    STDERR.puts response['reason']
  end
end

# Removes PL and related PA and PV, if they belong to the user,
# and if they are removable.
def delete_plant_line(plant_line_id)
  request = Net::HTTP::Get.new("/api/v1/plant_lines?only_mine=true&plant_line[query][id]=#{plant_line_id}", @headers)
  response = call_bip request

  if response['plant_lines'].count > 0
    plant_line = response['plant_lines'][0]
    puts "Found Plant Line #{plant_line['plant_line_name']}. Removing related Plant Accessions and a Plant Variety."

    plant_line['plant_accession_ids'].each do |plant_accession_id|
      delete_record 'plant_accessions', plant_accession_id
    end

    delete_record 'plant_varieties', plant_line['plant_variety_id']
    delete_record 'plant_lines', plant_line['id']
  end
end


# Step 1. Searching for the population id.

request = Net::HTTP::Get.new("/api/v1/plant_populations?only_mine=true&plant_population[query][name]=#{URI.escape ARGV[0]}", @headers)
response = call_bip request

if response['plant_populations'].count == 0
  STDERR.puts "Plant Population #{ARGV[0]} not found or it does not belong to you. Exiting."
  exit 1
end

plant_population = response['plant_populations'][0]
puts "Found the Plant Population, id = #{plant_population['id']}."


# Step 2. Traversing Plant Lines related to this population and deleting all related PVs and PAs

plant_population['plant_line_ids'].each do |plant_line_id|
  delete_plant_line(plant_line_id)
end

delete_record 'plant_populations', plant_population['id']
