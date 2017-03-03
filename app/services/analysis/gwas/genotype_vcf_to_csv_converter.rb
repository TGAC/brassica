require "csv"

class Analysis
  class Gwas
    class GenotypeVcfToCsvConverter
      def call(path)
        vcf_file = File.open(path, "r")
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

      ensure
        vcf_file && vcf_file.close
      end

      private

      def generate_genotype_csv(mutation_names, sample_data)
        headers = %w(ID) + mutation_names

        Tempfile.new(["genotype", ".csv"]).tap do |csv_file|
          csv_file.write(headers.join(",") + "\n")

          sample_data.each do |sample_name, mutations|
            csv_file.write(sample_name + ",")
            csv_file.write(mutations.join(",") + "\n")
          end

          csv_file.flush
          csv_file.rewind
        end
      end

      def generate_map_csv(mutation_names, mutation_data)
        headers = %w(ID Chr cM)

        Tempfile.new(["map", ".csv"]).tap do |csv_file|
          csv_file.write(headers.join(",") + "\n")

          mutation_names.each.with_index do |name, idx|
            chrom, pos = mutation_data[idx]
            csv_file.write([name, chrom, pos].join(",") + "\n")
          end

          csv_file.flush
          csv_file.rewind
        end
      end
    end
  end
end
