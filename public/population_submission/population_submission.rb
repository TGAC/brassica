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
@client.verify_mode = OpenSSL::SSL::VERIFY_NONE
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

#defining input columns from CSV
ACCESSION_NAME=0
LINE_NAME=1
SRA_IDENTIFIER=2
VARIETY=3
CROP_TYPE=4
ACCESSION_SOURCE=5







# Attempts to create a resource record with data. Returns the created object id.
def create_record(class_name, data)
  request = Net::HTTP::Post.new("/api/v1/#{pluralize_class class_name}", @headers)
  request.body = { class_name => data }.to_json
  response = call_bip request
  puts "#{response}"
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


puts " 1. Creating experimental plant_population "

create_record('plant_population',
  name: 'RIPR_test_population',
  description: '387 Brassica napus accessions used in the RIPR project for which mRNAseq data were submitted to SRA under PRJNA309367',
  establishing_organisation: 'York University',
  taxonomy_term_id: 27  #this is Brassica napus id in BIP
)


puts ' 2. Submitting plant_varieties'

def record_plant_variety(plant_variety_name, crop_type)
  request = Net::HTTP::Get.new("/api/v1/plant_varieties?plant_variety[query][plant_variety_name]=#{URI.escape plant_variety_name}", @headers)
  response = call_bip request
  if response['meta']['total_count'] == 0
    create_record('plant_variety',
      plant_variety_name: plant_variety_name,
      crop_type: crop_type
    )
  else
    response['plant_varieties'][0]['id']
  end
end


puts ' 3. Submitting plant_lines'

      def record_plant_lines(plant_line_name, plant_variety_name)
        request = Net::HTTP::Get.new("/api/v1/plant_linesplant_line[query][plant_line_name]=#{URI.escape plant_line_name}", @headers)
        response = call_bip request
        if response['meta']['total_count'] == 0
          create_record('plant_line',
          Plant_line_name: row[LINE_NAME],
          plant_variety_name: row[VARIETY])
        else
          response['plant_lines'][0]['id']
        end
      end

puts '4. Submitting plant_accessions'

      def record_plant_accessions(plant_accession, accession_originator,plant_variety_id, comments)
        request = Net::HTTP::Get.new("/api/v1/plant_accessions?plant_accession[query][plant_accession]=#{plant_accession}", @headers)
        response = call_bip request
        plant_accession_id = if response['meta']['total_count'] == 0
                      plant_variety_id = record_plant_variety(row[VARIETY], row[CROP_TYPE])
                        create_record('plant_accession',
                            plant_accession: row[ACCESSION_NAME],
                            originating_organisation: row[ACCESSION_SOURCE],
                            plant_variety_id: plant_variety_id,
                            comments: row[SRA_IDENTIFIER] #SRA identifier
                                     )
                             else
                       response['plant_accessions'][0]['id']
                     end
      end



# Now, parse the input scoring file and record all important information



CSV.foreach(ARGV[0]) do |row|
  next if row[0]== 'Accession_name' # omit the header
  puts "  * processing Accession  #{row[ACCESSION_NAME]}"
  record_plant_variety(row[VARIETY], row[CROP_TYPE])
end

puts '4. Finished'
