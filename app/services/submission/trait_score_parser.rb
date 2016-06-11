class Submission::TraitScoreParser

  attr_reader :trait_mapping, :trait_scores, :accessions, :replicate_numbers, :design_factors, :design_factor_names, :lines_or_varieties

  def initialize(upload)
    @upload = upload
  end

  def call
    @upload.log "Starting Trait Scores file parsing [file name: #{@upload.file_file_name}]"

    @upload.submission.content.update(:step04, trait_mapping: nil,
                                               trait_scores: nil,
                                               replicate_numbers: nil,
                                               design_factors: nil,
                                               design_factor_names: nil,
                                               accessions: nil,
                                               lines_or_varieties: nil)
    @upload.submission.save!

    begin
      parse_header
      parse_scores if @upload.errors.empty?
    rescue EOFError => e
      @upload.log "Input file finished"
    rescue ArgumentError => e
      @upload.log "Detected wrong file format - please make sure the file is not encoded (e.g. you are uploading an xls, instead of a text file)."
    end

    if @upload.errors.empty?
      @upload.submission.content.update(:step04,
                                        trait_mapping: @trait_mapping,
                                        replicate_numbers: @replicate_numbers,
                                        trait_scores: @trait_scores,
                                        design_factors: @design_factors,
                                        design_factor_names: @design_factor_names,
                                        accessions: @accessions,
                                        lines_or_varieties: @lines_or_varieties)
      @upload.submission.save!
      @upload.submission.content.save!
    end
  end

  private

  # Assumptions regarding the header (in this order):
  # - first column is sample id
  # - a 0+ set of columns with design factor names as headers
  # - column 'Plant accession'
  # - column 'Originating organisation'
  # - column 'Plant line' or 'Plant variety'
  # - trait name columns, preferably called exactly as the chosen traits
  #  - if technical replicates are present for a given trait, heir are expected to appear in order,
  #    denoted with the '_repX' suffix, where X starts with 1,
  #    e.g. "Trait name_rep1, Trait name_rep2, Another trait name_rep1"
  def parse_header
    header = csv.readline
    @trait_names = PlantTrialSubmissionDecorator.decorate(@upload.submission).sorted_trait_names
    @trait_mapping = {}
    @replicate_numbers = {}
    @design_factor_names = []
    @line_or_variety = 'PlantLine'
    replicates_present = false
    @number_of_design_factors = 0
    if header.blank? || header.size < 4
      @upload.errors.add(:file, :no_header)
    elsif header.index('Plant accession').nil?
      @upload.errors.add(:file, :no_plant_accession_header)
    elsif header.index('Plant line').nil? && header.index('Plant variety').nil?
      @upload.errors.add(:file, :no_line_or_variety_header)
    else
      @number_of_design_factors = [header.index('Plant accession') - 1, 0].max
      @upload.log "Interpreting design factors" if @number_of_design_factors > 0
      header[1, @number_of_design_factors].each do |design_factor_name|
        @design_factor_names << (design_factor_name ? design_factor_name.gsub('/','') : '')
      end

      @line_or_variety = 'PlantVariety' if header.index('Plant line').nil?

      @upload.log "Mapping file header columns to Trait Descriptors"
      replicates_present = detect_replication(header[4..-1])
      header[(4 + @number_of_design_factors)..-1].each_with_index do |column_name, i|
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
      @upload.errors.add(:file, :non_unique_mapping)
    end
  end

  def parse_scores
    @upload.log "Parsing scores for traits"
    plant_count = 0
    score_count = 0
    @trait_scores = {}
    @design_factors = {}
    @accessions = {}
    @lines_or_varieties = {}
    csv.each do |score_line|
      design_factors, score_line = score_line.partition.with_index do |_, i|
        i >= 1 && i <= @design_factor_names.size
      end
      plant_id, plant_accession, originating_organisation, line_name_or_variety_name, *values = score_line.map{ |d| d.nil? ? '' : d.strip }
      unless plant_id.blank?
        @design_factors[plant_id] = design_factors
        if plant_accession.blank? || originating_organisation.blank?
          @upload.log "Ignored row for #{plant_id} since either Plant accession or Originating organisation is missing."
        elsif line_name_or_variety_name.blank?
          @upload.log "Ignored row for #{plant_id} since #{@line_or_variety} value is missing."
        else
          @accessions[plant_id] = {
            plant_accession: plant_accession,
            originating_organisation: originating_organisation
          }
          @lines_or_varieties[plant_id] = {
            relation_class_name: @line_or_variety,
            relation_record_name: line_name_or_variety_name
          }
          @trait_scores[plant_id] = {}
          plant_count += 1
          values.each_with_index do |value, col_index|
            unless value.blank?
              if @trait_mapping[col_index].nil?
                @upload.log "Encountered too many scoring values for #{plant_id}. Ignoring value #{value} in column #{col_index + @design_factor_names.size + 5}."
              else
                @trait_scores[plant_id][col_index] = value
                score_count += 1
              end
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
    header_columns.any?{ |column_name| column_name && column_name.index(/rep\d+$/) }
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
