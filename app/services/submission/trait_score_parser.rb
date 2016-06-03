class Submission::TraitScoreParser

  attr_reader :trait_mapping, :trait_scores, :accessions, :replicate_numbers

  def initialize(upload)
    @upload = upload
  end

  def call
    @upload.log "Starting Trait Scores file parsing [file name: #{@upload.file_file_name}]"

    @upload.submission.content.update(:step03, trait_mapping: nil, trait_scores: nil)
    @upload.submission.save!

    begin
      map_headers_to_traits
      parse_scores if @upload.errors.empty?
    rescue EOFError => e
      @upload.log "Input file finished"
    rescue ArgumentError => e
      @upload.log "Detected wrong file format - please make sure the file is not encoded (e.g. you are uploading an xls, instead of a text file)."
    end

    if @upload.errors.empty?
      @upload.submission.content.update(:step03,
                                        trait_mapping: @trait_mapping,
                                        replicate_numbers: @replicate_numbers,
                                        trait_scores: @trait_scores,
                                        accessions: @accessions)
      @upload.submission.save!
      @upload.submission.content.save!
    end
  end

  private

  def map_headers_to_traits
    @upload.log "Mapping file header columns to Trait Descriptors"
    header = csv.readline
    @trait_names = PlantTrialSubmissionDecorator.decorate(@upload.submission).sorted_trait_names
    @trait_mapping = {}
    @replicate_numbers = {}
    replicates_present = false
    if header.blank? || header.size < 3
      @upload.errors.add(:file, 'No correct header provided. At least three columns are expected.')
    else
      replicates_present = detect_replication(header[3..-1])
      header[3..-1].each_with_index do |column_name, i|
        next if i >= @trait_names.length && !replicates_present
        trait_name, replicate_number = split_to_trait_and_replicate(column_name)
        trait_index = @trait_names.find_index(trait_name)
        unless trait_index.present?
          trait_index = i - replicate_adjustment
          trait_index -= 1 if replicate_number > 1
        end
        @trait_mapping[i] = trait_index
        @replicate_numbers[i] = replicate_number
        @upload.log " - Mapped column '#{column_name}' to Trait index #{trait_index} of value #{@trait_names[trait_index]}"
        if replicate_number > 0
          @upload.log "   - Detected technical replicate number #{replicate_number}"
        end
      end
    end
    if @trait_mapping.values.uniq.length != @trait_mapping.values.length && !replicates_present
      @upload.errors.add(:file, 'Detected non unique column headers mapping to traits. Please check the column names.')
    end
  end

  def parse_scores
    @upload.log "Parsing scores for traits"
    plant_count = 0
    score_count = 0
    @trait_scores = {}
    @accessions = {}
    csv.each do |score_line|
      plant_id, plant_accession, originating_organisation, *values = score_line.map{ |d| d.nil? ? '' : d.strip }
      unless plant_id.blank?
        if plant_accession.blank? || originating_organisation.blank?
          @upload.log "Ignored row for #{plant_id} since either Plant accession or Originating organisation is missing."
        else
          @accessions[plant_id] = {
            plant_accession: plant_accession,
            originating_organisation: originating_organisation
          }
          @trait_scores[plant_id] = {}
          plant_count += 1
          values.each_with_index do |value, col_index|
            unless value.blank? || @trait_mapping[col_index].nil?
              @trait_scores[plant_id][col_index] = value
              score_count += 1
            end
          end
        end
      end
    end
    @upload.log "Parsed #{score_count} scores for #{plant_count} plant scoring units, in total."
  end

  def csv
    @csv ||= CSV.new(input)
  end

  def input
    @input ||= File.open(@upload.file.path)
  end

  def detect_replication(header_columns)
    header_columns.any?{ |column_name| column_name.index /rep\d+$/ }
  end

  def split_to_trait_and_replicate(column_name)
    replicate_number = 0
    return ['',0] if column_name.blank?
    trait_name = column_name.strip.gsub(/rep\d+$/) do |replicate|
      replicate_number = replicate.gsub('rep','').to_i
      ''  # It will replace the match with ''
    end.strip
    [trait_name, replicate_number]
  end

  def replicate_adjustment
    @replicate_numbers.values.select{ |replicate_number| replicate_number > 1 }.size
  end
end
