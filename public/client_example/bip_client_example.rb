require 'csv'
require 'json'
require 'uri'
require 'net/http'
require 'net/https'

# A sample Ruby client which:
#  1. Creates (or finds pre-created) Trait Descriptors for the three tocopherol-related traits
#  2. Creates a new Plant Trial object representing the submitted study
#  3. Parses an input .csv file in search for trait scoring data
#  4. Submits that data to BIP using the BIP API Key provided

if ARGV.size < 2
  STDERR.puts 'Not enough arguments. Usage:'
  STDERR.puts ' > ruby bip_client_example.rb input_file.csv api_key'
  exit 1
end

@client = Net::HTTP.new('bip.tgac.ac.uk', 443)
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

# Attempts to create a resource record with data. Returns the created object id.
def create_record(class_name, data)
  request = Net::HTTP::Post.new("/api/v1/#{pluralize_class class_name}", @headers)
  request.body = { class_name => data }.to_json
  response = call_bip request
  if !response["errors"].nil? && response["errors"].size > 0
    STDERR.puts "Encountered the following error when creating #{class_name}."
    STDERR.puts response["errors"][0]["message"]
    exit 1
  end
  response[class_name]['id']
end

def test_error(response)
  unless response['reason'].nil?
    STDERR.puts "Encountered the following BIP request error."
    STDERR.puts response['reason']
    exit 1
  end
end

# You need Trait Descriptors to describe what traits were actually measured in your trial.
puts '1. Finding/Creating Trait Descriptors'
a_toc_id, y_toc_id, d_toc_id = ['Seed α-tocopherol', 'Seed γ-tocopherol', 'Seed δ-tocopherol'].map do |trait_name|
  encoded_name = URI.escape trait_name

  puts " - Looking for existing Trait #{trait_name} Descriptor"
  request = Net::HTTP::Get.new("/api/v1/trait_descriptors?trait_descriptor[search][traits.name]=#{encoded_name}", @headers)
  response = call_bip request

  if response['meta']['total_count'] == 0
    puts ' - No existing Trait Descriptor found, creating one'
    puts '  - Looking for adequate Trait'
    request = Net::HTTP::Get.new("/api/v1/traits?trait[search][name]=#{encoded_name}", @headers)
    response = call_bip request
    if response['meta']['total_count'] == 0
      STDERR.puts "No Trait with name [#{trait_name}] was found in BIP. Exiting."
      exit 1
    end
    trait_id = response['traits'][0]['id']

    puts '  - Looking for adequate seed Plant Part'
    request = Net::HTTP::Get.new('/api/v1/plant_parts?plant_part[search][plant_part]=seed', @headers)
    response = call_bip request
    plant_part_id = if response['meta']['total_count'] > 0
                      seed = response['plant_parts'].detect do |pp|
                        pp['plant_part'] == 'seed'
                      end
                      seed ? seed['id'] : nil
                    else
                      nil
                    end

    puts "  - Creating Trait Descriptor for #{trait_name}"
    create_record('trait_descriptor',
      descriptor_name: trait_name,
      units_of_measurements: 'μg/g',
      category: 'seed composition',
      scoring_method: 'Gas Chromatography',
      trait_id: trait_id,
      plant_part_id: plant_part_id
    )
  else
    puts "  - Found, trait_descriptor_id = #{response['trait_descriptors'][0]['id']}"
    response['trait_descriptors'][0]['id']
  end
end

puts '2. Creating a new Plant Trial record'
request = Net::HTTP::Get.new("/api/v1/countries?country[search][country_name]=#{URI.escape 'United Kingdom'}", @headers)
response = call_bip request
country_id = response['meta']['total_count'] > 0 ? response['countries'][0]['id'] : nil

plant_trial_id = create_record('plant_trial',
  plant_trial_name: 'Tocopherol seed content measurement - SAMPLE DEMO TRIAL.',
  project_descriptor: 'RIPR',
  trial_year: 2016,
  place_name: 'Norwich',
  country_id: country_id
)

puts '3. Creating PSUs and recording scores'

# Mapping of column number to BIP model
SAMPLE_ID = 0
DESIGN_FACTORS = [
  ['polytunnel', 2],
  ['rep', 3],
  ['sub_block', 4],
  ['pot_number', 5]
]
ACCESSION = 7
ACCESSION_ORGANISATION = 'Nottingham name'
VARIETY = 10
# Mapping of column number to trait and tech rep number
SCORING = {
  11 => { rep: 1, td_id: a_toc_id},
  12 => { rep: 2, td_id: a_toc_id},
  13 => { rep: 1, td_id: y_toc_id},
  14 => { rep: 2, td_id: y_toc_id},
  15 => { rep: 1, td_id: d_toc_id},
  16 => { rep: 2, td_id: d_toc_id}
}

# A helper function for:
# - looking for varieties in BIP, or
# - recording varieties which are not yet present in BIP.
def record_plant_variety(plant_variety_name)
  puts "    - finding/creating Plant Variety #{plant_variety_name}"

  request = Net::HTTP::Get.new("/api/v1/plant_varieties?plant_variety[query][plant_variety_name]=#{URI.escape plant_variety_name}", @headers)
  response = call_bip request
  if response['meta']['total_count'] == 0
    create_record('plant_variety', plant_variety_name: plant_variety_name)
  else
    response['plant_varieties'][0]['id']
  end
end

# Now, parse the input scoring file and record all important information
CSV.foreach(ARGV[0]) do |row|
  next if row[0] == 'plant_sample_id'  # the header

  puts "  * processing Plant Scoring Unit #{row[SAMPLE_ID]}"
  puts "    - finding/creating Plant Accession #{row[ACCESSION]}"

  # Each plant scoring unit requires an accession; we need to either find it in BIP or create a new one
  plant_accession = URI.escape(row[ACCESSION])
  request = Net::HTTP::Get.new("/api/v1/plant_accessions?plant_accession[query][plant_accession]=#{plant_accession}", @headers)
  response = call_bip request

  plant_accession_id = if response['meta']['total_count'] == 0
                         plant_variety_id = record_plant_variety(row[VARIETY])
                         create_record('plant_accession',
                           plant_accession: row[ACCESSION],
                           originating_organisation: ACCESSION_ORGANISATION,
                           plant_variety_id: plant_variety_id
                         )
                       else
                         response['plant_accessions'][0]['id']
                       end

  puts "    - creating Plant Scoring Unit #{row[SAMPLE_ID]}"

  # Design factors are important to record as they tell other users what experiment layout we used
  design_factors_array = DESIGN_FACTORS.map do |factor_name, column|
    "#{factor_name}_#{row[column].to_i}"
  end
  design_factor_id = create_record('design_factor',
                                   design_factors: design_factors_array,
                                   design_unit_counter: row[DESIGN_FACTORS.last[1]]
                                  )

  # New, we create a new plant scoring unit; in our sample case, it represents a single plant
  sample_id = URI.escape row[SAMPLE_ID]
  psu_id = create_record('plant_scoring_unit',
                         scoring_unit_name: sample_id,
                         plant_accession_id: plant_accession_id,
                         plant_trial_id: plant_trial_id,
                         design_factor_id: design_factor_id
                        )

  SCORING.each do |column, trait_data|
    unless row[column].nil? || row[column].strip.empty?
      puts "    - recording score #{row[column]} for #{trait_data[:td_id]} [rep: #{trait_data[:rep]}]"
      create_record('trait_score',
        score_value: row[column],
        technical_replicate_number: trait_data[:rep],
        plant_scoring_unit_id: psu_id,
        trait_descriptor_id: trait_data[:td_id]
      )
    end
  end
end

puts '4. Finished'
