class Analysis
    module Gwas
    class PlantTrialPhenotypeCsvBuilder
      def build(plant_trial)
        documents = exporter(plant_trial).documents

        trait_descriptors = CSV.new(documents.fetch(:trait_descriptors))
        trait_id_idx = trait_descriptors.readline.index("Trait")
        trait_ids = trait_descriptors.map { |row| row[trait_id_idx] }

        trait_scoring = CSV.new(documents.fetch(:trait_scoring))
        trait_scoring_headers = trait_scoring.readline
        trait_id_indices = trait_ids.map { |trait_id| trait_scoring_headers.index(trait_id) }

        sample_id_idx = trait_scoring_headers.index("Scoring unit name")
        sample_ids = trait_scoring.map { |row| row[sample_id_idx] }

        # Reset position to the first data line
        trait_scoring.rewind; trait_scoring.readline

        Result.new(trait_ids, trait_id_indices, sample_ids, trait_scoring)
      end

      def build_csv(plant_trial)
        data = build(plant_trial)

        # TODO: make sure normalized names are unique
        trait_ids = data.trait_ids.map { |trait_id| trait_id.gsub(/\W+/, "_") }
        headers = %w(ID) + trait_ids

        tmpfile = NamedTempfile.new(".csv").tap do |csv_file|
          csv_file << CSV.generate(force_quotes: true) do |csv|
            csv << headers

            data.scoring.each do |sample|
              sample = sample.map { |val| val == "-" ? "NA" : val }
              scores = data.trait_id_indices.map { |idx| sample[idx] }

              csv << [sample[0]] + scores
            end
          end

          csv_file.original_filename = "plant-trial-phenotype.csv"
          csv_file.flush
          csv_file.rewind
        end

        [tmpfile, trait_ids]
      end

      private

      def exporter(plant_trial)
        Submission::PlantTrialExporter.
          new(OpenStruct.new(submitted_object: plant_trial, user: plant_trial.user))
      end

      class Result
        attr_reader :trait_ids, :trait_id_indices, :sample_ids, :scoring

        def initialize(trait_ids, trait_id_indices, sample_ids, scoring)
          @trait_ids = trait_ids
          @trait_id_indices = trait_id_indices
          @sample_ids = sample_ids
          @scoring = scoring
        end

        def valid?; true; end
        def errors; []; end
      end
    end
  end
end
