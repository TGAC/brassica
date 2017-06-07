require "csv"

class Analysis
  class Gwas
    class GenotypeVcfToCsvConverter
      def call(path)
        File.open(path, "r") do |vcf_file|
          vcf_data = Analysis::Gwas::GenotypeVcfParser.new.call(vcf_file)

          raise unless vcf_data.valid?

          mutation_names = []
          mutation_data = []
          sample_data = Hash.new { |data, sample_name| data[sample_name] = [] }

          vcf_data.each_record do |record|
            record.alt.each.with_index do |alternative, idx|
              alternative_no = idx + 1
              sample_values = []

              vcf_data.sample_ids.each do |sample_name|
                sample = record.sample_by_name(sample_name)
                value = sample_value(sample, alternative_no)

                sample_values << [sample_name, value]
              end

              unique_values = sample_values.map { |_, val| val }.uniq

              if (unique_values - ["NA"]).size > 1
                mutation_names << "#{record.id}_#{record.ref}_#{alternative}".strip.gsub(/\W/, '_')
                mutation_data << [record.chrom.to_s.strip, record.pos.to_s.strip]

                sample_values.each { |sample_name, val| sample_data[sample_name] << val }
              end
            end
          end

          [
            generate_genotype_csv(mutation_names, sample_data),
            generate_map_csv(mutation_names, mutation_data)
          ]
        end
      end

      private

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
        if sample.empty?
          "NA" # call could not be made
        else
          alternative_count = sample.gti.count { |allele_no| allele_no == alternative_no }
          if sample.gti.size == alternative_count
            2
          elsif alternative_count > 0
            1
          else
            0
          end
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
