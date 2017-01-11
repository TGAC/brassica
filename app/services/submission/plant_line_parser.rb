class Submission::PlantLineParser

  attr_reader :plant_lines

  def initialize(upload)
    @upload = upload
  end

  def call
    @upload.log "Starting Plant Lines file parsing [file name: #{@upload.file_file_name}]"

    begin
      parse_header
      parse_plant_lines if @upload.errors.empty?
    rescue EOFError => e
      @upload.log "Input file finished"
    rescue ArgumentError => e
      @upload.log "Detected wrong file format - please make sure the file is not encoded (e.g. you are uploading an xls, instead of a text file)."
    end

    if @upload.errors.empty?
      @upload.submission.content.append(:step03,
                                        plant_line_list: plant_line_names,
                                        new_plant_lines: @plant_lines,
                                        new_plant_varieties: @plant_varieties,
                                        new_plant_accessions: @plant_accessions)
      @upload.submission.save!
      @upload.submission.content.save!
    end
  end

  private

  def parse_header
    header = csv.readline
    if header.blank?
      @upload.errors.add(:file, :no_header_plant_lines)
    elsif header.index('Plant line').nil?
      @upload.errors.add(:file, :no_plant_line_header)
    elsif header.index('Plant variety').nil?
      @upload.errors.add(:file, :no_plant_variety_header)
    elsif header.index('Crop type').nil?
      @upload.errors.add(:file, :no_crop_type_header)
    elsif header.index('Species').nil?
      @upload.errors.add(:file, :no_species_header)
    elsif header.index('Plant accession').nil?
      @upload.errors.add(:file, :no_plant_accession_header)
    elsif header.index('Originating organisation').nil?
      @upload.errors.add(:file, :no_originating_organisation_header)
    elsif header.index('Year produced').nil?
      @upload.errors.add(:file, :no_year_produced_header)
    end
  end

  def parse_plant_lines
    @upload.log "Parsing Plant Lines data"
    @plant_lines = []
    @plant_varieties = {}
    @plant_accessions = {}
    csv.each do |row|
      next unless correct_input?(row)
      species, plant_variety_name, crop_type, plant_line_name, plant_accession, originating_organisation, year_produced = parse_row(row)
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
        taxonomy_term: species
      }
    end
    @upload.log "Parsed #{@plant_lines.size} correct plant line(s)."
    @upload.log "Out of them, #{@plant_accessions.size} have plant accession(s) defined."
    @upload.log "Detected #{@plant_varieties.size} plant line(s) of new (i.e. not existing in BIP) plant variety(ies)."
  end

  def csv
    @csv ||= CSV.new(input)
  end

  def input
    @input ||= File.open(@upload.file.path)
  end

  def correct_input?(row)
    species, _plant_variety_name, _crop_type, plant_line_name, plant_accession, originating_organisation, year_produced = parse_row(row)
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
    elsif existing_plant_accession?(plant_accession, originating_organisation)
      @upload.log "Ignored row for #{plant_line_name} since it refers to a plant accession which currently exists in BIP."
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

  def parse_row(row)
    row.map { |d| d.nil? ? '' : d.strip }
  end

  def plant_line_names
    @plant_lines.map { |plant_line| plant_line[:plant_line_name] }
  end

  def new_plant_variety?(plant_variety_name)
    plant_variety_name.present? &&
      PlantVariety.find_by_plant_variety_name(plant_variety_name).blank?
  end

  def existing_plant_accession?(plant_accession, originating_organisation)
    PlantAccession.where(
      plant_accession: plant_accession,
      originating_organisation: originating_organisation).present?
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
