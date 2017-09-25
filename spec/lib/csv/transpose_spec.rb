require "rails_helper"

RSpec.describe CSV::Transpose do
  let(:input) { fixture_file("example.csv", "text/csv") }

  after do
    input.unlink
  end

  it "does stuff" do
    CSV::Transpose.new(input.path).call(force_quotes: true)

    expect(CSV.read(input.path)).to eq([
      ["A", "00", "10", "",   "30"],
      ["B", "01", "11", "21", "31"],
      ["C", "02", "12", "22", "32"],
      ["D", "03", "",   "23", "33"]
    ])
  end
end
