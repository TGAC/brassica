# Parses CSV, populates #errors and #logs attributes on upload object.
class Submission::PlantLineUploadProcessor

  attr_reader :plant_lines, :plant_accessions

  def initialize(upload, io = nil)
    @upload = upload
    @io = io || File.open(@upload.file.path, "r")
  end

  def call
    @upload.log "Starting Plant Lines file parsing [file name: #{@upload.file_file_name}]"

    parse_upload
    process_upload if @upload.errors.empty?
    update_submission if @upload.errors.empty?

  rescue EOFError => e
    @upload.log "Input file finished"
  rescue ArgumentError => e
    # TODO make this more specific, detect bad utf-8 encoding
    @upload.log "Detected wrong file format - please make sure the file is not encoded (e.g. you are uploading an xls, instead of a text file)."
  ensure
    @io.close
  end

  private

  def parse_upload
    @parsed_upload = Submission::PlantLineCsvParser.new.call(@io)
    @parsed_upload.errors.each { |e| @upload.errors.add(:file, *e) }
  end

  def process_upload
    @upload.log "Parsing Plant Lines data"
    @plant_lines = []
    @plant_varieties = {}
    @plant_accessions = {}
    @parsed_upload.each do |row|
      next unless correct_input?(row)
      species, plant_variety_name, crop_type, plant_line_name, common_name, previous_line_name, genetic_status, sequence, plant_accession, originating_organisation, year_produced = row
      if new_plant_variety?(plant_variety_name)
        @plant_varieties[plant_line_name] = {
          plant_variety_name: plant_variety_name,
          crop_type: crop_type
        }
      end
      if [plant_accession, originating_organisation, year_produced].all?(&:present?)
        @plant_accessions[plant_line_name] = {
          plant_accession: plant_accession,
          originating_organisation: originating_organisation,
          year_produced: year_produced
        }
      end
      @plant_lines << {
        plant_line_name: plant_line_name,
        plant_variety_name: plant_variety_name,
        taxonomy_term: species,
        common_name: common_name,
        previous_line_name: previous_line_name,
        genetic_status: genetic_status,
        sequence_identifier: sequence
      }
    end
    @upload.log "Parsed #{@plant_lines.size} correct plant line(s)."
    @upload.log "Out of them, #{@plant_accessions.size} have plant accession(s) defined."
    @upload.log "Detected #{@plant_varieties.size} plant line(s) of new (i.e. not existing in BIP) plant variety(ies)."
  end

  def update_submission
    @upload.submission.content.append(:step03,
                                      plant_line_list: plant_line_names,
                                      new_plant_lines: @plant_lines,
                                      new_plant_varieties: @plant_varieties,
                                      new_plant_accessions: @plant_accessions)
    @upload.submission.content.update(:step03, uploaded_plant_lines: @plant_lines)
    @upload.submission.save!
    @upload.submission.content.save!
  end

  def correct_input?(row)
    species, _plant_variety_name, _crop_type, plant_line_name, _common_name, _previous_line_name, _genetic_status, _sequence, plant_accession, originating_organisation, year_produced = row
    return false if plant_line_name.blank?
    if plant_line_names.include? plant_line_name
      @upload.log "Ignored row for #{plant_line_name} since a plant line with that name is already defined in the uploaded file."
    elsif current_plant_lines.include? plant_line_name
      @upload.log "Ignored row for #{plant_line_name} since a plant line with that name is already defined. Please clear the 'Plant line list' field before re-uploading a CSV file."
    elsif reused_plant_line?(plant_line_name)
      @upload.log "Ignored row for #{plant_line_name} since a plant line with that name is already present in BIP."\
                  "Please use the 'Plant line list' field to add this existing plant line to the submitted population."
    elsif species.blank?
      @upload.log "Ignored row for #{plant_line_name} since Species name is missing."
    elsif existing_plant_accession?(plant_accession, originating_organisation, year_produced)
      @upload.log "Ignored row for #{plant_line_name} since it refers to a plant accession which currently exists in BIP."\
                  "If your intention was to refer to an existing accession, please leave the Plant accession, Originating organisation and Year produced values blank for this plant line."
    elsif incomplete_plant_accession?(plant_accession, originating_organisation, year_produced)
      @upload.log "Ignored row for #{plant_line_name} since incomplete plant accession was given."\
                  "Either all or none of the Plant accession, Originating organisation and Year produced values must be provided."
    elsif reused_plant_accession?(plant_accession, originating_organisation, year_produced)
      @upload.log "Ignored row for #{plant_line_name} since the defined plant accession was already used for another plant line in this file."
    elsif TaxonomyTerm.find_by_name(species).blank?
      @upload.log "Ignored row for #{plant_line_name} since taxonomy unit called #{species} was not found in BIP."
    else
      return true
    end
    false
  end

  def plant_line_names
    @plant_lines.map { |plant_line| plant_line[:plant_line_name] }
  end

  def new_plant_variety?(plant_variety_name)
    plant_variety_name.present? &&
      PlantVariety.find_by_plant_variety_name(plant_variety_name).blank?
  end

  def existing_plant_accession?(plant_accession, originating_organisation, year_produced)
    PlantAccession.where(
      plant_accession: plant_accession,
      originating_organisation: originating_organisation,
      year_produced: year_produced).present?
  end

  def incomplete_plant_accession?(*pa_data)
    pa_data.any?(&:present?) && pa_data.any?(&:blank?)
  end

  def reused_plant_line?(plant_line_name)
    PlantLine.find_by(plant_line_name: plant_line_name)
  end

  def reused_plant_accession?(plant_accession, originating_organisation, year_produced)
    @plant_accessions.any? do |_, pa|
      pa[:plant_accession] == plant_accession &&
        pa[:originating_organisation] == originating_organisation &&
        pa[:year_produced] == year_produced
    end
  end

  def current_plant_lines
    @current_plant_lines ||= @upload.submission.content.step03.plant_line_list || []
  end
end
