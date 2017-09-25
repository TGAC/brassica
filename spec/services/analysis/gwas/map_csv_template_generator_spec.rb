require "rails_helper"

RSpec.describe Analysis::Gwas::MapCsvTemplateGenerator do
  subject { described_class.new.call }

  it "returns a CSV string" do
    expect(subject.split("\n").first).to eq("ID,Chr,cM")
  end
end
