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
      # TODO FIXME rather add uploaded PLs to the existing list (of e.g. manually created PLs) instead of replacing everything
      @upload.submission.content.update(:step03,
                                        plant_line_list: plant_line_names,
                                        new_plant_lines: @plant_lines)
      @upload.submission.save!
      @upload.submission.content.save!
    end
  end

  private

  def parse_header
    header = csv.readline
    if header.blank? || header.size < 3
      @upload.errors.add(:file, :no_header)
    elsif header.index('Plant line').nil?
      @upload.errors.add(:file, :no_plant_line_header)
    elsif header.index('Plant variety').nil?
      @upload.errors.add(:file, :no_plant_variety_header)
    elsif header.index('Species').nil?
      @upload.errors.add(:file, :no_species_header)
    end
  end

  def parse_plant_lines
    @upload.log "Parsing Plant Lines data"
    @plant_lines = []
    csv.each do |row|
      species, plant_variety_name, plant_line_name = row.map{ |d| d.nil? ? '' : d.strip }
      unless plant_line_name.blank?
        if plant_line_names.include? plant_line_name
          @upload.log "Ignored row for #{plant_line_name} since a plant line with that name is already defined in the uploaded file."
        elsif species.blank?
          @upload.log "Ignored row for #{plant_line_name} since Species name is missing."
        elsif plant_variety_name.blank?
          @upload.log "Ignored row for #{plant_line_name} since Plant variety name is missing."
        elsif TaxonomyTerm.find_by_name(species).blank?
          @upload.log "Ignored row for #{plant_line_name} since taxonomy unit called #{species} was not found in BIP."
        elsif PlantVariety.find_by_plant_variety_name(plant_variety_name).blank?
          @upload.log "Ignored row for #{plant_line_name} since Plant variety called #{plant_variety_name} was not found in BIP."
        else
          @plant_lines << {
            plant_line_name: plant_line_name,
            plant_variety: plant_variety_name,
            taxonomy_term: species
          }
        end
      end
    end
  end

  def csv
    @csv ||= CSV.new(input)
  end

  def input
    @input ||= File.open(@upload.file.path)
  end

  def plant_line_names
    @plant_lines.map{ |plant_line| plant_line[:plant_line_name] }
  end
end
