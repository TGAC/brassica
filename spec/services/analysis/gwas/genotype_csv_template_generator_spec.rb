require "rails_helper"

RSpec.describe Analysis::Gwas::GenotypeCsvTemplateGenerator do
  subject { described_class.new.call }

  it "returns a CSV string" do
    expect(subject.split("\n").first).to eq("ID,SNP-1,SNP-2,SNP-3,SNP-4")
  end
end
