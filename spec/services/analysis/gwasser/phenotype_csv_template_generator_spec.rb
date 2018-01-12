require "rails_helper"

RSpec.describe Analysis::Gwasser::PhenotypeCsvTemplateGenerator do
  subject { described_class.new.call }

  it "returns a CSV string" do
    expect(subject.split("\n").first).to eq("ID,Trait-1,Trait-2,Trait-3,Trait-4")
  end
end
