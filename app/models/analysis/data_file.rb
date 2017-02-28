class Analysis::DataFile < ActiveRecord::Base
  BASE_DATA_TYPES = %w(std_out std_err)
  GWAS_DATA_TYPES = %w(gwas_genotype gwas_phenotype gwas_map gwas_results)

  enum data_type: BASE_DATA_TYPES | GWAS_DATA_TYPES
  enum role: %w(input output)

  belongs_to :owner, class_name: "User"
  belongs_to :analysis

  has_attached_file :file

  validates :owner, presence: true
  validates :file, attachment_presence: true,
                   attachment_size: { less_than: 50.megabytes },
                   attachment_file_name: { matches: /\.(vcf|csv|txt)\Z/ }

  do_not_validate_attachment_file_type :file

  delegate :url, to: :file, prefix: true

  scope :csv, -> { where(file_content_type: CSV_CONTENT_TYPES) }
  scope :vcf, -> { where("file_file_name ILIKE '%.vcf'") }
end
