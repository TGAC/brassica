class Submission::PlantLineProcessor

  attr_reader :plant_line_names, :new_plant_lines, :new_plant_varieties, :new_plant_accessions

  def initialize(upload, parser = Submission::PlantLineParser.new)
    @upload = upload
    @parser = parser
  end

  def call
    parse_upload
    process_upload if @upload.errors.empty?
    update_submission_content if @upload.errors.empty?
  end

  private

  def parse_upload
    @upload.log "Starting Plant Lines file parsing [file name: #{@upload.file_file_name}]"

    @parser_result = @parser.call(@upload.file.path)
    @parser_result.errors.each { |error| @upload.errors.add(:file, *error) } unless @parser_result.valid?
  end

  def process_upload
    @upload.log "Parsing Plant Lines data"
    @plant_line_names = []
    @new_plant_lines = []
    @new_plant_varieties = {}
    @new_plant_accessions = {}

    @parser_result.rows.each do |pv_attrs, pl_attrs, pa_attrs|
      next unless correct_input?(pv_attrs, pl_attrs, pa_attrs)

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

  def update_submission_content
    remove_overriden_content
    append_uploaded_content

    @upload.submission.save!
  end

  def remove_overriden_content
    current_new_plant_lines = @upload.submission.content.new_plant_lines || []
    current_new_plant_varieties = @upload.submission.content.new_plant_varieties || {}
    current_new_plant_accessions = @upload.submission.content.new_plant_accessions || {}

    overriden_new_plant_lines =
      current_new_plant_lines.select { |npl| @plant_line_names.include?(npl.fetch("plant_line_name")) }

    @upload.submission.content.update(:step03,
                                      new_plant_lines: current_new_plant_lines - overriden_new_plant_lines,
                                      new_plant_varieties: current_new_plant_varieties.except(*@plant_line_names),
                                      new_plant_accessions: current_new_plant_accessions.except(*@plant_line_names))
  end

  def append_uploaded_content
    @upload.submission.content.append(:step03,
                                      plant_line_list: @plant_line_names,
                                      new_plant_lines: @new_plant_lines,
                                      new_plant_varieties: @new_plant_varieties,
                                      new_plant_accessions: @new_plant_accessions)
    @upload.submission.content.update(:step03, uploaded_plant_lines: @plant_line_names)
  end

  def correct_input?(pv_attrs, pl_attrs, pa_attrs)
    plant_line_name = pl_attrs[:plant_line_name]
    taxonomy_term_name = pl_attrs[:taxonomy_term]

    return false if plant_line_name.blank?

    if reused_plant_line?(plant_line_name)
      @upload.log "Ignored row for #{plant_line_name} since a plant line with that name is already defined in the uploaded file."
    elsif existing_plant_line?(plant_line_name) && !existing_plant_line_match?(pl_attrs, pv_attrs)
      @upload.log "Ignored row for #{plant_line_name} since a plant line with that name is already present in BIP "\
                  "but uploaded data does not match existing record."
    elsif taxonomy_term_name.blank? && !existing_plant_line?(plant_line_name)
      @upload.log "Ignored row for #{plant_line_name} since Species name is missing."
    elsif taxonomy_term_name.present? && TaxonomyTerm.find_by_name(taxonomy_term_name).blank?
      @upload.log "Ignored row for #{plant_line_name} since taxonomy unit called #{taxonomy_term_name} was not found in BIP."
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
    taxonomy_term = pl_attrs[:taxonomy_term]

    return false if pv_attrs.any? { |attr, val| existing_line.plant_variety.try(attr) != val }
    return false if pl_attrs.except(:taxonomy_term).any? { |attr, val| existing_line.try(attr) != val }
    return false if taxonomy_term && taxonomy_term != existing_line.taxonomy_term.try(:name)

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
end
