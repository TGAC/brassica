require "csv"

class Analysis
  class Gwas
    class GenotypeHapmapToCsvConverter
      def call(path)
        File.open(path, "r") do |hapmap_file|
          hapmap_data = Analysis::Gwas::GenotypeHapmapParser.new.call(hapmap_file)

          raise unless hapmap_data.valid?

          mutation_names = []
          mutation_data = []
          sample_data = Hash.new { |data, sample_name| data[sample_name] = [] }

          hapmap_data.each_record do |record|
            # TODO: headers should not appear here
            next if record[0] == "rs#"

            record_data = process_record(record, hapmap_data.sample_ids)

            next unless record_data

            mutation_names << record_data[:mutation_name]
            mutation_data << record_data[:mutation_data]

            record_data[:sample_values].each do |sample_name, value|
              sample_data[sample_name] << value
            end
          end

          [
            :ok,
            generate_genotype_csv(mutation_names, sample_data),
            generate_map_csv(mutation_names, mutation_data)
          ]
        end
      end

      private

      # Extract mutation and samples data from a single hapmap record. One record
      # holds information about one mutation and multiple samples.
      #
      # If there is no variation (i.e. there is only one distinct value apart
      # from NA for each sample) for the mutation then record is silently skipped.
      #
      # Special characters apart from underscore are stripped from sample and
      # mutation identifiers.
      #
      # record - hapmap record
      # sample_ids - original hapmap sample identifiers
      #
      # Returns a hash containing mutation name, position and value for each sample.
      def process_record(record, sample_ids)
        # TODO pass records as structs instead of arrays
        mutation_name = record[0]
        mutation_data = [record[2], record[3]] # chrom, pos
        sample_values = []

        sample_ids.each.with_index do |sample_name, sample_idx|
          mutation = record[1] # definition
          sample = record[11 + sample_idx] # first sample is in 11th column (0-based)
          value = sample_value(mutation, sample)

          sample_values << [sample_name, value]
        end

        unique_values = sample_values.map { |_, val| val }.uniq

        return if (unique_values - ["NA"]).size <= 1

        {
          mutation_name: mutation_name,
          mutation_data: mutation_data,
          sample_values: sample_values
        }
      end

      # Find number of alternative alleles for given sample.
      #
      # mutation - definition of mutation (e.g. A/C)
      # sample - sample alleles (e.g. AA, AC, CC)
      #
      # Returns:
      #   2 for alternative allele in each chromosome
      #   1 for alternative allele in any chromosome
      #   0 for no mutation
      #   NA if call could not be made
      def sample_value(mutation, sample)
        _original, alternative = mutation.split("/")

        alternative_count = sample.split("").count { |allele| allele == alternative }

        if sample.length == alternative_count
          2
        elsif alternative_count > 0
          1
        else
          0
        end
      end

      def generate_genotype_csv(mutation_names, sample_data)
        Tempfile.new(["genotype", ".csv"]).tap do |csv_file|
          csv_file << CSV.generate(force_quotes: true) do |csv|
            csv << %w(ID) + mutation_names

            sample_data.each do |sample_name, mutations|
              csv << [sample_name] + mutations
            end
          end

          csv_file.flush
          csv_file.rewind
        end
      end

      def generate_map_csv(mutation_names, mutation_data)
        Tempfile.new(["map", ".csv"]).tap do |csv_file|
          csv_file << CSV.generate(force_quotes: true) do |csv|
            csv << %w(ID Chr cM)

            mutation_names.each.with_index do |name, idx|
              chrom, pos = mutation_data[idx]
              csv << [name, chrom, pos]
            end
          end

          csv_file.flush
          csv_file.rewind
        end
      end
    end
  end
end
