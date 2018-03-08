class Analysis::DataFile < ActiveRecord::Base
  BASE_DATA_TYPES = %w(std_out std_err)
  GWAS_DATA_TYPES = %w(gwas_genotype gwas_phenotype gwas_map gwas_results gwas_aux_results)

  enum data_type: BASE_DATA_TYPES | GWAS_DATA_TYPES
  enum role: %w(input output)
  enum origin: %w(uploaded generated)

  belongs_to :owner, class_name: "User"
  belongs_to :analysis

  has_attached_file :file

  validates :owner, presence: true
  validates :file, attachment_presence: true
  validates :file, attachment_size: { less_than: 50.megabytes },
                   attachment_file_name: { matches: /\.(vcf|hapmap|csv|txt)\Z/ },
                   if: :uploaded?

  validates :file_format, inclusion: { in: %w(vcf hapmap csv txt), message: :invalid_for_gwas_genotype },
                          if: :gwas_genotype?

  do_not_validate_attachment_file_type :file

  before_validation :assign_file_format, on: :create
  after_commit :normalize_line_breaks, on: :create, if: :uploaded?

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
    elsif File.read(path, 3).to_s.starts_with?("rs")
      self.file_format = :hapmap
    elsif CSV_CONTENT_TYPES.include?(file.content_type)
      self.file_format = :csv
    elsif path.match(/.txt\z/)
      self.file_format = :txt
    end
  end
end
