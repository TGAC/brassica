class Analysis::DataFile < ActiveRecord::Base
  BASE_DATA_TYPES = %w(std_out std_err)
  GWAS_DATA_TYPES = %w(gwas_genotype gwas_phenotype gwas_map gwas_results)

  enum data_type: BASE_DATA_TYPES | GWAS_DATA_TYPES
  enum role: %w(input output)
  enum origin: %w(uploaded generated)

  belongs_to :owner, class_name: "User"
  belongs_to :analysis

  has_attached_file :file

  validates :owner, presence: true
  validates :file, attachment_presence: true,
                   attachment_size: { less_than: 50.megabytes },
                   attachment_file_name: { matches: /\.(vcf|hapmap|csv|txt)\Z/ }

  do_not_validate_attachment_file_type :file

  after_commit :normalize_line_breaks, on: :create
  before_validation :assign_file_format, on: :create

  delegate :url, to: :file, prefix: true

  scope :csv, -> { where(file_format: :csv) }
  scope :vcf, -> { where(file_format: :vcf) }
  scope :hapmap, -> { where(file_format: :hapmap) }

  private

  def normalize_line_breaks
    LineBreakNormalizer.new.call(file.path)
  end

  def assign_file_format
    path = file.queued_for_write[:original].try(:path)

    return unless path

    if path.match(/.vcf\z/)
      self.file_format = :vcf
    elsif File.read(path, 3) == "rs#"
      self.file_format = :hapmap
    elsif CSV_CONTENT_TYPES.include?(file.content_type)
      self.file_format = :csv
    elsif path.match(/.txt\z/)
      self.file_format = :txt
    end
  end
end
