class Analysis
  class Gwas
    class PlantTrialPhenotypeBuilder
      def build(plant_trial)
        documents = exporter(plant_trial).documents

        # TODO: move to Result object
        trait_descriptors = CSV.new(documents.fetch(:trait_descriptors))

        trait_id_idx = trait_descriptors.readline.index("Trait")
        trait_ids = trait_descriptors.map { |row| row[trait_id_idx] }

        trial_scoring = CSV.new(documents.fetch(:trait_scoring))
        sample_id_idx = trial_scoring.readline.index("Scoring unit name")
        sample_ids = trial_scoring.map { |row| row[sample_id_idx] }

        trial_scoring.rewind

        Result.new(trait_ids, sample_ids, trial_scoring)
      end

      def build_csv(plant_trial)
        data = build(plant_trial)

        scoring_headers = data.scoring.readline
        headers = %w(ID) + data.trait_ids

        min_trait_id_idx = data.trait_ids.map { |trait_id| scoring_headers.index(trait_id) }.min

        Tempfile.new(["plant-trial-phenotype", ".csv"]).tap do |csv_file|
          csv_file.write(headers.join(",") + "\n")

          data.scoring.each do |sample|
            sample = sample.map { |val| val == "-" ? "NA" : val }

            csv_file.write(sample[0] + ",")
            csv_file.write(sample[min_trait_id_idx..-1].join(",") + "\n")
          end

          csv_file.flush
          csv_file.rewind
        end
      end

      private

      def exporter(plant_trial)
        Submission::PlantTrialExporter.
          new(OpenStruct.new(submitted_object: plant_trial, user: plant_trial.user))
      end

      class Result
        attr_reader :trait_ids, :sample_ids, :scoring

        def initialize(trait_ids, sample_ids, scoring)
          @trait_ids = trait_ids
          @sample_ids = sample_ids
          @scoring = scoring
        end

        def valid?; true; end
        def errors; []; end
      end
    end
  end
end
