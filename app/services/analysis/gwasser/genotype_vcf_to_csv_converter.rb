require "csv"

class Analysis
  class Gwasser
    class GenotypeVcfToCsvConverter
      def call(path)
        File.open(path, "r") do |vcf_file|
          vcf_data = Analysis::Gwasser::GenotypeVcfParser.new.call(vcf_file)

          raise unless vcf_data.valid?

          mutation_names = []
          mutation_data = []
          removed_mutation_names = []
          sample_data = Hash.new { |data, sample_name| data[sample_name] = [] }

          vcf_data.each_record do |record|
            record_data = process_record(record, vcf_data.sample_ids)

            next unless record_data

            mutation_names += record_data[:mutation_names]
            mutation_data += record_data[:mutation_data]
            removed_mutation_names += record_data[:removed_mutation_names]

            record_data[:sample_data].each do |sample_name, values|
              sample_data[sample_name] += values
            end
          end

          return :all_mutations_removed unless mutation_names.present?

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

      # Extract mutation and samples data from a single VCF record. If VCF record
      # specifies more than one mutation (alternative base) it needs to be mapped to more
      # than one CSV column.
      #
      # If there is no variation (i.e. there is only one distinct value apart
      # from NA for each sample) for given mutation then it is silently skipped.
      #
      # Special characters apart from underscore are stripped from sample and
      # mutation identifiers.
      #
      # record - VCF record
      # sample_ids - original VCF sample identifiers
      #
      # Returns a hash containing mutation names, positions and
      #   values for each sample.
      def process_record(record, sample_ids)
        mutation_names = []
        mutation_data = []
        removed_mutation_names = []
        sample_data = Hash.new { |data, sample_name| data[sample_name] = [] }

        record.alt.each.with_index do |alternative, idx|
          alternative_no = idx + 1
          sample_values = []

          sample_ids.each do |sample_name|
            sample = record.sample_by_name(sample_name)
            value = sample_value(sample, alternative_no)

            sample_values << [sample_name, value]
          end

          mutation_name = "#{record.id}_#{record.ref}_#{alternative}".strip.gsub(/\W/, '_')
          unique_values = sample_values.map { |_, val| val }.uniq

          if (unique_values - ["NA"]).size > 1
            # TODO: make sure normalized names are unique
            mutation_names << mutation_name
            mutation_data << [record.chrom.to_s.strip, record.pos.to_s.strip]

            sample_values.each { |sample_name, val| sample_data[sample_name] << val }
          else
            removed_mutation_names << mutation_name
          end
        end

        {
          mutation_names: mutation_names,
          mutation_data: mutation_data,
          sample_data: sample_data,
          removed_mutation_names: removed_mutation_names
        }
      end

      # Find number of alternative alleles for given sample.
      #
      # sample - sample data (including position in genotype)
      # alternative_no - ordinal number of alternative base (1-based,
      #
      # Returns:
      #   2 for alternative allele in each chromosome
      #   1 for alternative allele in any chromosome
      #   0 for no mutation
      #   NA if call could not be made
      def sample_value(sample, alternative_no)
        return "NA" if sample.empty?

        alternative_count = sample.gti.count { |allele_no| allele_no == alternative_no }
        if sample.gti.size == alternative_count
          2
        elsif alternative_count > 0
          1
        else
          0
        end
      end

      def generate_genotype_csv(mutation_names, sample_data)
        NamedTempfile.new(".csv").tap do |csv_file|
          csv_file << CSV.generate(force_quotes: true) do |csv|
            csv << %w(ID) + mutation_names

            sample_data.each do |sample_name, mutations|
              csv << [sample_name] + mutations
            end
          end

          csv_file.original_filename = "genotype.csv"
          csv_file.flush
          csv_file.rewind
        end
      end

      def generate_map_csv(mutation_names, mutation_data)
        NamedTempfile.new(".csv").tap do |csv_file|
          csv_file << CSV.generate(force_quotes: true) do |csv|
            csv << %w(ID Chr cM)

            mutation_names.each.with_index do |name, idx|
              chrom, pos = mutation_data[idx]
              csv << [name, chrom, pos]
            end
          end

          csv_file.original_filename = "map.csv"
          csv_file.flush
          csv_file.rewind
        end
      end
    end
  end
end
