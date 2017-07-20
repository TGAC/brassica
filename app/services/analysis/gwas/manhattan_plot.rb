class Analysis
  class Gwas
    class ManhattanPlot
      def initialize(analysis, cutoff: nil)
        self.analysis = analysis
        self.cutoff = cutoff
      end

      def call
        { traits: [] }.tap do |results|
          chromosomes = Hash.new { |h, k| h[k] = [] }

          result_data_files.each do |data_file|
            trait, mutations = process_trait(data_file)

            mutations.each_with_index do |(_, _, chrom, _), idx|
              chromosomes[chrom] << idx
            end if mutations.present? && mutations.first.size > 2

            results[:traits] << [trait, mutations]
          end

          apply_cutoff(results[:traits])
          append_tooltips(results[:traits])

          results[:cutoff] =  cutoff

          results[:chromosomes] = chromosomes.map do |chrom, indices|
            [chrom, indices.min, indices.max]
          end
        end
      end

      private

      attr_accessor :analysis, :cutoff

      def result_data_files
        analysis.data_files.gwas_results
      end

      def process_trait(data_file)
        neg_log10_p_values = {}
        mutations = nil

        # TODO: looks brittle - maybe metadata should be added to datafiles?
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
              # TODO: handle NA values without casting to floats
              [name, neg_log10_p_values[name.gsub(/\W/, '_')].to_f, chrom, pos.to_i]
            end
          end

          mutations = mutations.sort do |mut_a, mut_b|
            chrom_a, pos_a = mut_a[-2..-1]
            chrom_b, pos_b = mut_b[-2..-1]

            if chrom_a.match(/\d/) && chrom_b.match(/\d/)
              chrom_a = chrom_a.gsub(/\D+/, '').to_i
              chrom_b = chrom_b.gsub(/\D+/, '').to_i
            end

            chrom_a == chrom_b ? pos_a <=> pos_b : chrom_a <=> chrom_b
          end

        else
          mutations = neg_log10_p_values.transform_values { |value| value.to_f }.to_a
        end

        [trait, mutations]
      end

      def apply_cutoff(traits_data)
        compute_cutoff(traits_data) unless cutoff

        return unless cutoff > 0

        traits_data.each.with_index do |(_, mutations), idx|
          traits_data[idx][1] = mutations.select { |_, neg_log10_p| neg_log10_p >= cutoff }
        end
      end

      def compute_cutoff(traits_data)
        return self.cutoff = 0 unless count_mutations(traits_data) > 10_000

        [5, 2, 1, 0.5, 0].each do |candidate|
          self.cutoff = candidate

          break if traits_data.any? do |trait, mutations|
            mutations.count { |_, neg_log10_p| neg_log10_p >= cutoff } > 0
          end
        end
      end

      def count_mutations(traits_data)
        traits_data.sum(0) { |_, mutations| mutations.size }
      end

      def append_tooltips(traits_data)
        traits_data.each.with_index do |(_, mutations), idx|
          traits_data[idx] << mutations.map { |mut| format_tooltip(*mut) }
        end
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
