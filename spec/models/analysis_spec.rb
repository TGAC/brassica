require "rails_helper"

RSpec.describe Analysis do
  it { should validate_presence_of(:owner) }
  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(250) }
  it { should validate_numericality_of(:associated_pid).only_integer.allow_nil }
  it { should define_enum_for(:analysis_type).with(%w(gwasser gapit)) }
  it { should define_enum_for(:status).with(%w(idle running success failure)) }
  it { should have_many(:data_files).class_name("Analysis::DataFile") }
  it { should have_db_column(:finished_at).of_type(:datetime) }
end
