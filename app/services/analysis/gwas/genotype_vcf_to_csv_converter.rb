require "csv"

class Analysis
  class Gwas
    class GenotypeVcfToCsvConverter
      def call(path)
        vcf_file = File.open(path, "r")
        vcf_data = Analysis::Gwas::GenotypeVcfParser.new.call(vcf_file)

        raise unless vcf_data.valid?

        mutation_names = []
        sample_data = Hash.new { |data, sample_name| data[sample_name] = [] }

        vcf_data.each_record do |record|
          mutation_name = record.id != "." ? record.id : [record.chrom, record.pos.to_s].join(".")
          mutation_names << mutation_name

          vcf_data.sample_ids.each do |sample_name|
            sample = record.sample_by_name(sample_name)

            # 1 = unaff, 2 = aff, 0 = miss
            #
            # TODO: this needs to be confirmed
            value = if sample.empty?
                      "NA"
                    elsif sample.gti.all? { |val| val == "." }
                      0
                    elsif sample.gti.any? { |val| val > 0 }
                      2
                    else
                      1
                    end

            sample_data[sample_name] << value
          end
        end

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
      ensure
        vcf_file && vcf_file.close
      end
    end
  end
end
