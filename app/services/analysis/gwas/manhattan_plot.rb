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
            neg_log10_p_values = {}
            mutations = nil
            tooltips = []

            # TODO: looks brittle - maybe metadata could be added to datafiles?
            trait = data_file.file_file_name.match(/SNPAssociation-Full-(.*)\.csv$/)[1]

            CSV.foreach(data_file.file.path) do |name, _, neg_log10_p|
              # TODO: fix GWASSER so that it does not output invalid row ID.1
              next if name =~ /\AID(\.1)?\z/

              neg_log10_p_values[name] = neg_log10_p
            end

            if map_csv_data_file = analysis.data_files.gwas_map.first
              File.open(map_csv_data_file.file.path, "r") do |file|
                map_data = Analysis::Gwas::MapCsvParser.new.call(file)
                mutations = map_data.csv.map do |name, chrom, pos|
                  [name, neg_log10_p_values[name], chrom, pos]
                end
              end

              mutations = mutations.sort { |mut_a, mut_b|
                chrom_a, pos_a = mut_a[-2..-1]
                chrom_b, pos_b = mut_b[-2..-1]

                chrom_a == chrom_b ? pos_a <=> pos_b : chrom_a <=> chrom_b
              }

              mutations.each_with_index do |(_, _, chrom, _), idx|
                chromosomes[chrom] << idx
              end

            # TODO: consider creating a map file for VCF too
            elsif genotype_vcf_data_file = analysis.data_files.gwas_genotype.vcf.first
              File.open(genotype_vcf_data_file.file.path, "r") do |file|
                vcf_data = Analysis::Gwas::GenotypeVcfParser.new.call(file)
                mutations = vcf_data.each_record.map do |record|
                  [record.id, neg_log10_p_values[record.id], record.chrom, record.pos]
                end.force
              end

              mutations = mutations.sort { |mut_a, mut_b|
                chrom_a, pos_a = mut_a[-2..-1]
                chrom_b, pos_b = mut_b[-2..-1]

                chrom_a == chrom_b ? pos_a <=> pos_b : chrom_a <=> chrom_b
              }

              mutations.each_with_index do |(_, _, chrom, _), idx|
                chromosomes[chrom] << idx
              end
            else
              mutations = neg_log10_p_values.to_a
            end


            tooltips = mutations.map { |mut| format_tooltip(*mut) }

            results[:traits] << [trait, mutations, tooltips]
          end

          results[:chromosomes] = chromosomes.map do |chrom, indices|
            [chrom, indices.min, indices.max]
          end
        end
      end

      private

      def result_data_files
        analysis.data_files.gwas_results
      end

      def format_tooltip(mut, neg_log10_p, chrom = nil, pos = nil)
        unless neg_log10_p == "NA"
          neg_log10_p = "%.4f" % neg_log10_p
        end

        tooltip = <<-TOOLTIP.strip_heredoc
          <br>Mutation: #{mut}
          <br>-log10(p-value): #{neg_log10_p}
        TOOLTIP

        tooltip.tap do |t|
          t << "<br>Chromosome: #{chrom}" if chrom
          t << "<br>Position: #{pos}" if pos
        end
      end
    end
  end
end
