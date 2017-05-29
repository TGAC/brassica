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
              mutation_names << "#{record.id}-#{record.ref}-#{alternative}"
              mutation_data << [record.chrom, record.pos]

              vcf_data.sample_ids.each do |sample_name|
                sample = record.sample_by_name(sample_name)

                if sample.empty?
                  value = "NA" # call cannot be made
                else
                  alternative_count = sample.gti.count { |allele_no| allele_no == alternative_no }
                  value = if sample.gti.size == alternative_count
                            # alternative allele in each chromosome
                            2
                          elsif alternative_count > 0
                            # alternative allele in one chromosome only
                            1
                          else
                            # no mutation
                            0
                          end
                end

                sample_data[sample_name] << value
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
