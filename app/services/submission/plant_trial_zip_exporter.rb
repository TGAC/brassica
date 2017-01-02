require 'zip'

class Submission::PlantTrialZipExporter
  def call(plant_trial, cache_key)
    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      documents = Rails.cache.fetch(cache_key, expires_in: 300.days) do
        Rails.logger.info 'MISS MISS MISS'
        exporter = Submission::PlantTrialExporter.new(
          OpenStruct.new(submitted_object: plant_trial, user: plant_trial.user)
        )
        exporter.documents
      end
      documents.each do |document_name, content|
        filename = "#{document_name}.csv"
        zos.put_next_entry filename
        zos.print content
      end
    end
    compressed_filestream.rewind
    compressed_filestream
  end
end
