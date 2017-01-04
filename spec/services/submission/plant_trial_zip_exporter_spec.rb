require "rails_helper"

RSpec.describe Submission::PlantTrialZipExporter do
  let(:plant_trial) { create(:plant_trial) }
  before(:each) do
    create(:trait_score, plant_scoring_unit: create(:plant_scoring_unit, plant_trial: plant_trial))
  end

  describe "#call" do
    before(:each) { Rails.cache.clear }

    it 'compress three files in the zip file' do
      csv_data = Submission::PlantTrialZipExporter.new.call(plant_trial, 'cache_key').read
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

    it 'caches response when same cache key is used' do
      expect_any_instance_of(Submission::PlantTrialExporter).to receive(:documents).once.and_call_original
      Submission::PlantTrialZipExporter.new.call(plant_trial, 'same_cache_key').read
      Submission::PlantTrialZipExporter.new.call(plant_trial, 'same_cache_key').read
    end

    it 'refreshes cache when different cache key is used' do
      expect(plant_trial).to receive(:scoring_table_data).twice.and_call_original
      Submission::PlantTrialZipExporter.new.call(plant_trial, 'one_cache_key').read
      Submission::PlantTrialZipExporter.new.call(plant_trial, 'another_cache_key').read
    end
  end
end
