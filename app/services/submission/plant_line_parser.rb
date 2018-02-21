class Submission::PlantLineParser

  attr_reader :plant_line_names, :new_plant_lines, :new_plant_varieties, :new_plant_accessions

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
                                        plant_line_list: @plant_line_names,
                                        new_plant_lines: @new_plant_lines,
                                        new_plant_varieties: @new_plant_varieties,
                                        new_plant_accessions: @new_plant_accessions)
      @upload.submission.content.update(:step03, uploaded_plant_lines: @plant_line_names)
      @upload.submission.save!
      @upload.submission.content.save!
    end
  end

  private

  def parse_header
    header = csv.readline
    if header.blank?
      @upload.errors.add(:file, :no_header_plant_lines)
      return
    end

    header_columns.each do |column_name|
      if header.index(column_name).nil?
        @upload.errors.add(:file, "no_#{column_name.downcase.parameterize('_')}_header".to_sym)
      end
    end
  end

  def parse_plant_lines
    @upload.log "Parsing Plant Lines data"
    @plant_line_names = []
    @new_plant_lines = []
    @new_plant_varieties = {}
    @new_plant_accessions = {}

    csv.each do |row|
      next unless correct_input?(row)

      pv_attrs, pl_attrs, pa_attrs = parse_row(row)
      plant_line_name = pl_attrs.fetch(:plant_line_name)
      plant_variety_name = pv_attrs[:plant_variety_name]

      @new_plant_varieties[plant_line_name] = pv_attrs if new_plant_variety?(plant_variety_name)

      if complete_plant_accession?(pa_attrs) && !existing_plant_accession?(pa_attrs)
        @new_plant_accessions[plant_line_name] = pa_attrs
      end

      @plant_line_names << plant_line_name

      unless existing_plant_line(plant_line_name).present?
        @new_plant_lines << pl_attrs.merge(plant_variety_name: plant_variety_name)
      end
    end

    @upload.log "Parsed #{@plant_line_names.size} correct plant line(s)."
    @upload.log "Out of them, #{@new_plant_lines.size} are new."
    @upload.log "Out of them, #{@new_plant_accessions.size} have plant accession(s) defined."
    @upload.log "Detected #{@new_plant_varieties.size} plant line(s) of new (i.e. not existing in BIP) plant variety(ies)."
  end

  def csv
    @csv ||= CSV.new(input)
  end

  def input
    @input ||= File.open(@upload.file.path)
  end

  def correct_input?(row)
    pv_attrs, pl_attrs, pa_attrs = parse_row(row)

    plant_line_name = pl_attrs[:plant_line_name]
    taxonomy_term_name = pl_attrs[:taxonomy_term]

    return false if plant_line_name.blank?

    if taxonomy_term_name.blank?
      @upload.log "Ignored row for #{plant_line_name} since Species name is missing."
    elsif TaxonomyTerm.find_by_name(taxonomy_term_name).blank?
      @upload.log "Ignored row for #{plant_line_name} since taxonomy unit called #{taxonomy_term_name} was not found in BIP."
    elsif reused_plant_line?(plant_line_name)
      @upload.log "Ignored row for #{plant_line_name} since a plant line with that name is already defined in the uploaded file."
    elsif current_new_plant_lines.include?(plant_line_name)
      @upload.log "Ignored row for #{plant_line_name} since a plant line with that name is already defined. Please clear the 'Plant line list' field before re-uploading a CSV file."
    elsif existing_plant_line?(plant_line_name) && !existing_plant_line_match?(pl_attrs, pv_attrs)
      @upload.log "Ignored row for #{plant_line_name} since a plant line with that name is already present in BIP "\
                  "but uploaded data does not match existing record."
    elsif existing_plant_accession?(pa_attrs) && !existing_plant_accession_match?(pa_attrs, plant_line_name)
      @upload.log "Ignored row for #{plant_line_name} since it refers to a plant accession which currently exists in BIP and belongs to other plant line."
    elsif incomplete_plant_accession?(pa_attrs)
      @upload.log "Ignored row for #{plant_line_name} since incomplete plant accession was given. "\
                  "Either all or none of the Plant accession, Originating organisation and Year produced values must be provided."
    elsif reused_plant_accession?(pa_attrs)
      @upload.log "Ignored row for #{plant_line_name} since the defined plant accession was already used for another plant line in this file."
    else
      return true
    end
    false
  end

  def parse_row(row)
    row = row.map { |d| d ? d.strip : d }

    [
      { plant_variety_name: row[1], crop_type: row[2] }.compact,
      { plant_line_name: row[3], common_name: row[4], previous_line_name: row[5],
        genetic_status: row[6], sequence_identifier: row[7], taxonomy_term: row[0] }.compact,
      { plant_accession: row[8], originating_organisation: row[9], year_produced: row[10] }.compact
    ]
  end

  def new_plant_variety?(plant_variety_name)
    plant_variety_name.present? && PlantVariety.where(plant_variety_name: plant_variety_name).blank?
  end

  def existing_plant_accession?(pa_attrs)
    existing_plant_accession(pa_attrs).present?
  end

  def existing_plant_accession_match?(pa_attrs, plant_line_name)
    existing_accession = existing_plant_accession(pa_attrs)
    existing_accession.plant_line.plant_line_name == plant_line_name
  end

  def existing_plant_accession(pa_attrs)
    pa_attrs.present? && PlantAccession.find_by(pa_attrs)
  end

  def complete_plant_accession?(plant_accession: nil, originating_organisation: nil, year_produced: nil)
    plant_accession.present? && originating_organisation.present? && year_produced.present?
  end

  def incomplete_plant_accession?(pa_attrs)
    pa_attrs.present? && !complete_plant_accession?(pa_attrs)
  end

  def reused_plant_accession?(plant_accession: nil, originating_organisation: nil, year_produced: nil)
    @new_plant_accessions.any? do |_, pa|
      pa[:plant_accession] == plant_accession &&
        pa[:originating_organisation] == originating_organisation &&
        pa[:year_produced] == year_produced
    end
  end

  def reused_plant_line?(plant_line_name)
    @plant_line_names.include?(plant_line_name)
  end

  def existing_plant_line?(plant_line_name)
    existing_plant_line(plant_line_name).present?
  end

  def existing_plant_line_match?(pl_attrs, pv_attrs)
    existing_line = existing_plant_line(pl_attrs.fetch(:plant_line_name))

    return false if pv_attrs.any? { |attr, val| existing_line.plant_variety.try(attr) != val }
    return false if pl_attrs.except(:taxonomy_term).any? { |attr, val| existing_line.try(attr) != val }
    return false if pl_attrs.fetch(:taxonomy_term) != existing_line.taxonomy_term.try(:name)

    true
  end

  def existing_plant_line(plant_line_name)
    PlantLine.
      visible(@upload.submission.user_id).
      find_by(plant_line_name: plant_line_name)
  end

  def current_plant_lines
    @current_plant_lines ||= @upload.submission.content.plant_line_list || []
  end

  def current_new_plant_lines
    @current_new_plant_lines ||= (@upload.submission.content.new_plant_lines || []).map { |pl| pl["plant_line_name"] }
  end

  def header_columns
    [
      "Species",
      "Plant variety",
      "Crop type",
      "Plant line",
      "Common name",
      "Previous line name",
      "Genetic status",
      "Sequence",
      "Plant accession",
      "Originating organisation",
      "Year produced"
    ]
  end
end
