class Analysis
  class Gwas
    class ManhattanPlot
      attr_reader :analysis

      def initialize(analysis)
        @analysis = analysis
      end

      def call
        { traits: [], chromosomes: [] }.tap do |results|

          chromosomes = Hash.new { |h, k| h[k] = [] }

          result_data_files.each.with_index do |data_file, trait_idx|
            tooltips = []
            mutations = []

            # TODO: looks brittle - maybe metadata could be added to datafiles?
            trait = data_file.file_file_name.match(/SNPAssociation-Full-(.*)\.csv$/)[1]

            CSV.foreach(data_file.file.path).with_index do |row, row_idx|
              # TODO: fix GWASSER so that it does not output invalid row ID.1
              next if row[0] =~ /\AID(\.1)?\z/

              mutations << row.values_at(0, 2) # mutation name, -log10(p-value)
            end

            # TODO: consider creating a map file
            if genotype_vcf_data_file = analysis.data_files.gwas_genotype.vcf.first
              File.open(genotype_vcf_data_file.file.path, "r") do |file|
                vcf_data = Analysis::Gwas::GenotypeVcfParser.new.call(file)
                vcf_data.each_record.with_index do |record, idx|
                  mutations[idx] << record.chrom << record.pos
                  tooltips << format_tooltip(*mutations[idx])
                  chromosomes[record.chrom] << idx
                end
              end
            else
              mutations.each do |name, neg_log_10_p|
                tooltips << format_tooltip(name, neg_log_10_p)
              end
            end

            results[:traits] << [trait, mutations, tooltips]
          end

          # TODO: check if there is no overlap - if there is it means that VCF data
          # was not sorted by chromosome
          results[:chromosomes] = chromosomes.map do |chrom, indices|
            [chrom, indices.min, indices.max]
          end
        end
      end

      private

      def result_data_files
        analysis.data_files.gwas_results
      end

      def format_tooltip(mut, neg_log_10_p, chrom = nil, pos = nil)
        unless neg_log_10_p == "NA"
          neg_log_10_p = "%.4f" % neg_log_10_p
        end

        tooltip = <<-TOOLTIP.strip_heredoc
          <br>Mutation: #{mut}
          <br>-log10(p-value): #{neg_log_10_p}
        TOOLTIP

        tooltip.tap do |t|
          t << "<br>Chromosome: #{chrom}" if chrom
          t << "<br>Position: #{pos}" if pos
        end
      end
    end
  end
end
