require 'csv'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'

# A BIP Ruby client which, given a Plant Trial name, fetches:
#  * all Trait Scores
#  * ....
# and produces a CSV to standard output, with each Plant Scoring Unit represented by a row.

if ARGV.size < 2
  STDERR.puts 'Not enough arguments. Usage:'
  STDERR.puts ' > ruby trial_analysis.rb plant_trial_name api_key'
  exit 1
end

@client = Net::HTTP.new('bip.earlham.ac.uk', 443)
@client.use_ssl = true
@headers = {
  'Content-Type' => 'application/json',
  'X-BIP-Api-Key' => ARGV[1]
}

def pluralize_class(class_name)
  class_name == 'plant_variety' ? 'plant_varieties' : "#{class_name}s"
end

def call_bip(request)
  response = @client.request(request)
  JSON.parse(response.body).tap{ |parsed| test_error(parsed) }
end

def test_error(response)
  unless response['reason'].nil?
    STDERR.puts "Encountered the following BIP request error."
    STDERR.puts response['reason']
    exit 1
  end
end

outputs = {}

STDERR.puts '1. Finding the Plant Trial'

trial_encoded_name = URI.escape ARGV[0]
request = Net::HTTP::Get.new("/api/v1/plant_trials?plant_trial[query][plant_trial_name]=#{trial_encoded_name}", @headers)
response = call_bip request

if response['meta']['total_count'] == 0
  STDERR.puts "Plant Trial called #{trial_encoded_name} was not found. Exiting."
  exit 1
end

plant_trial_id = response['plant_trials'][0]['id']

STDERR.puts "  - Found, plant_trial_id = #{plant_trial_id}"

STDERR.puts '2. Loading all Trait Scores for this Plant Trial.'
STDERR.print '  - Progress: '

trait_scores = []
page = 1
loop do
  request = Net::HTTP::Get.new("/api/v1/trait_scores?trait_score[query][plant_scoring_units.plant_trial_id]=#{plant_trial_id}&page=#{page}&per_page=200", @headers)
  response = call_bip request
  break if response['trait_scores'].size == 0
  trait_scores += response['trait_scores']
  STDERR.print '.'
  page += 1
end

STDERR.puts "\n  - #{trait_scores.size} Trait Scores loaded"

STDERR.puts '3. Finding Trait Descriptors'

trait_descriptor_ids = trait_scores.map{ |ts| ts['trait_descriptor_id'] }.uniq
ids_param = trait_descriptor_ids.map{ |td_id| "trait_descriptor[query][id][]=#{td_id}" }.join("&")
request = Net::HTTP::Get.new("/api/v1/trait_descriptors?#{ids_param}", @headers)
response = call_bip request
trait_descriptors = response['trait_descriptors']

STDERR.puts "  - The Trait Descriptors scored in this Plant Trial: #{trait_descriptors.map{ |td| td['trait']['name'] }}"

STDERR.puts '4. Iterating through Plant Scoring Units'

page = 1
loop do
  request = Net::HTTP::Get.new("/api/v1/plant_scoring_units?plant_scoring_unit[query][plant_trials.id]=#{plant_trial_id}&page=#{page}&per_page=200", @headers)
  response = call_bip request
  break if response['plant_scoring_units'].size == 0
  response['plant_scoring_units'].each do |plant_scoring_unit|
    outputs[plant_scoring_unit['scoring_unit_name']] = {}
    outputs[plant_scoring_unit['scoring_unit_name']]['trait_scores'] =
      trait_scores.select{ |ts| ts['plant_scoring_unit_id'] == plant_scoring_unit['id'] }
  end
  page += 1
end

STDERR.puts '5. Generating output CSV to STDOUT'

csv_string = CSV.generate do |csv|
  csv << ["Sample id"] + trait_descriptors.map{ |td| td['trait']['name'] }
  outputs.each do |scoring_unit_name, data|
    csv << [scoring_unit_name] + trait_descriptors.map{ |td| data['trait_scores'].detect{ |ts| ts['trait_descriptor_id'] == td['id'] }['score_value']}
  end
end

puts csv_string

STDERR.puts '6. Finished'
