require "rails_helper"

RSpec.describe Submission::PlantTrialZipExporter do
  let(:plant_trial) { create(:plant_trial) }
  before(:each) do
    create(:trait_score, plant_scoring_unit: create(:plant_scoring_unit, plant_trial: plant_trial))
  end

  describe "#call" do
    it 'compress three files in the zip file' do
      csv_data = Submission::PlantTrialZipExporter.new.call(plant_trial, 'no_cache').read
      file = Tempfile.new('plant_trial')
      file.write(csv_data)
      file.close
      Zip::File.open(file.path) do |zfile|
        data = zfile.map do |entry|
          [entry.name, entry.get_input_stream.read]
        end
        expect(data.map(&:first)).
          to match_array %w(plant_trial.csv trait_descriptors.csv trait_scoring.csv)
        expect(data.map{ |d| d[1].lines.size }).to match_array [2,2,2]
      end
    end
  end
end
