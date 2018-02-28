require "rails_helper"

RSpec.describe Analysis::DataFile do
  it { should define_enum_for(:role).with(%w(input output)) }
  it { should define_enum_for(:data_type).
       with(%w(std_out std_err gwas_genotype gwas_phenotype gwas_map gwas_results gwas_aux_results)) }
  it { should define_enum_for(:origin).with(%w(uploaded generated)) }

  it { should belong_to(:owner).class_name("User") }
  it { should belong_to(:analysis) }
  it { should have_attached_file(:file) }

  it { should validate_presence_of(:owner) }
  it { should validate_attachment_presence(:file) }
end
