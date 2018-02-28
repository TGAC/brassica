class UpdateAnalysisMetadataTraitResults < ActiveRecord::Migration
  def up
    Analysis.gwasser.each do |analysis|
      analysis.data_files.gwas_results.each do |data_file|
        data_file.origin = :generated
        data_file.save!
      end

      trait_results = analysis.data_files.gwas_results.map(&:file_file_name).map do |filename|
        [filename.match(/SNPAssociation-Full-(.*)\.csv$/)[1], filename]
      end

      analysis.meta["traits_results"] = Hash[trait_results]
      analysis.save!
    end
  end

  def down
  end
end
