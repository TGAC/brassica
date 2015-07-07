class Submission::TraitScoreParser

  attr_reader :trait_mapping

  def initialize(upload)
    @upload = upload
  end

  def call
    @upload.log "Starting Trait Scores file parsing [file name: #{@upload.file_file_name}]"
    # TODO FIXME remove all step03 content so we do not "stack" too many TraitScores

    begin
      map_headers_to_traits
    rescue EOFError => e
      @upload.log "Input file finished"
    end

    Rails.logger.debug @upload.errors[:file]

    if @upload.errors.empty?
      @upload.submission.content.update(:step03, trait_mapping: @trait_mapping)
    else
      Rails.logger.debug @upload.errors[:file]
    end

    Rails.logger.debug @upload.logs.join('\n')
  end

  private

  def map_headers_to_traits
    @upload.log "Mapping file header columns to Trait Descriptors"
    header = input.readline
    @trait_names = PlantTrialSubmissionDecorator.decorate(@upload.submission).sorted_trait_names
    @trait_mapping = {}
    header.split("\t")[1..-1].each_with_index do |column_name, i|
      next if i >= @trait_names.length
      column_name = column_name.strip
      trait_index = @trait_names.find_index(column_name)
      trait_index = i unless trait_index.present?
      @trait_mapping[i] = trait_index
      @upload.log " - Mapped column '#{column_name}' to Trait index #{trait_index} of value #{@trait_names[trait_index]}"
    end
    if @trait_mapping.values.uniq.length != @trait_mapping.values.length
      @upload.errors.add(:file, 'Detected non unique column headers mapping to traits. Please check the column names.')
    end
  end

  def input
    @input || (@input = File.open(@upload.file.path))
  end
end
