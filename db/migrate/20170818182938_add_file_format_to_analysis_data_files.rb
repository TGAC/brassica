class AddFileFormatToAnalysisDataFiles < ActiveRecord::Migration
  def up
    add_column :analysis_data_files, :file_format, :string

    Analysis::DataFile.where(file_content_type: CSV_CONTENT_TYPES).update_all(file_format: :csv)
    Analysis::DataFile.where("file_file_name ILIKE '%.vcf'").update_all(file_format: :vcf)
  end

  def down
    remove_column :analysis_data_files, :file_format
  end
end
