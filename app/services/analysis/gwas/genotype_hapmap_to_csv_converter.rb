require "csv"

class Analysis
  module Gwas
    class GenotypeHapmapToCsvConverter
      def call(path)
        File.open(path, "r") do |hapmap_file|
          hapmap_data = Analysis::Gwas::GenotypeHapmapParser.new.call(hapmap_file)

          raise unless hapmap_data.valid?

          mutation_names = []
          mutation_data = []
          removed_mutation_names = []
          sample_data = Hash.new { |data, sample_name| data[sample_name] = [] }

          hapmap_data.each_record do |record|
            record_status, record_data = process_record(record)

            case record_status
            when :ok
              mutation_names << record_data[:mutation_name]
              mutation_data << record_data[:mutation_data]

              record_data[:sample_values].each do |sample_name, value|
                sample_data[sample_name] << value
              end

            when :removed
              removed_mutation_names << record_data[:mutation_name]
            end
          end

          [
            :ok,
            generate_genotype_csv(mutation_names, sample_data),
            generate_map_csv(mutation_names, mutation_data),
            removed_mutation_names,
            sample_data.keys
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
      # record - hapmap record
      #
      # Returns a hash containing mutation name, position and value for each sample.
      def process_record(record)
        mutation_name = record.rs.strip
        mutation_data = [record.chrom, record.pos]
        sample_values = []

        record.sample_ids.each.with_index do |sample_name, sample_idx|
          value = sample_value(record.alleles, record.samples[sample_idx])

          sample_values << [sample_name, value]
        end

        unique_values = sample_values.map { |_, val| val }.uniq

        return [:removed, { mutation_name: mutation_name }] if (unique_values - ["NA"]).size <= 1

        [:ok, {
          mutation_name: mutation_name,
          mutation_data: mutation_data,
          sample_values: sample_values
        }]
      end

      # Find number of alternative alleles for given sample.
      #
      # mutation - definition of mutation (e.g. A/C, only basic codes are valid)
      # sample - sample alleles (e.g. AA, AC, CC, NN, all IUPAC codes are valid)
      #
      # Returns:
      #   2 for alternative allele in each chromosome
      #   1 for alternative allele in any chromosome
      #   0 for no mutation
      #   NA if call could not be made
      def sample_value(mutation, sample)
        verify_mutation(mutation)
        verify_sample(sample)

        _original, alternative = mutation.split("/")

        return "NA" if na_codes.include?(alternative)
        return "NA" if sample.chars.any? { |allele| base_codes.exclude?(allele) && codes_map.fetch(allele).include?(alternative) }

        alternative_count = sample.chars.count { |allele| codes_map.fetch(allele) == [alternative] }

        if sample.length == alternative_count
          2
        elsif alternative_count > 0
          1
        else
          0
        end
      end

      def verify_mutation(mutation)
        alleles = mutation.split("/")
        fail "Invalid mutation specification '#{mutation}'." unless alleles.size == 2
        fail "Value #{alleles} not valid in mutation specification." if alleles.any? { |allele| base_codes.exclude?(allele) }
      end

      def verify_sample(sample)
        return if na_codes.include?(sample)
        fail "Value #{sample} not understood" if sample.chars.any? { |allele| codes.exclude?(allele) }
      end

      def base_codes
        %w(A C G T)
      end

      def na_codes
        @na_codes ||= ["NN", "?"]
      end

      def codes_map
        @codes_map ||= {
          "A" => %w(A),
          "C" => %w(C),
          "G" => %w(G),
          "T" => %w(T),
          "R" => %w(A G),
          "Y" => %w(C T),
          "S" => %w(G C),
          "W" => %w(A T),
          "K" => %w(G T),
          "M" => %w(A C),
          "B" => %w(C G T),
          "D" => %w(A G T),
          "H" => %w(A C T),
          "V" => %w(A C G),
          "N" => %w(A C G T)
        }
      end

      def codes
        @codes ||= codes_map.keys
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
