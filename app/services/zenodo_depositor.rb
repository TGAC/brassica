# Service that deposits data in Zenodo.org
class ZenodoDepositor
  attr_accessor :user_log

  def initialize(deposition)
    @deposition = deposition
    @user_log = []
  end

  # 1. Sets up a new deposition in Zenodo, with proper metadata
  # 2. Uploads CSV data to that deposition
  # 3. Publishes that deposition (i.e. makes it available to public)
  # 4. Saves assigned DOI in submission
  def call
    unless @deposition.try(:valid?)
      raise ArgumentError, 'Got nil or invalid Deposition. Unable to upload it to Zenodo.'
    end

    return unless check_documents_presence

    request_deposition do |response|
      remote_deposition = JSON.parse(response.body)

      deposited_file_count = 0
      # We need a temp dir for deposition files
      Dir.mktmpdir do |files_directory|
        documents_to_deposit.each do |name, contents|
          file = write_file(contents, files_directory, "#{name}.csv")
          request_file_upload(remote_deposition, file) do |_|
            deposited_file_count += 1
          end
        end
      end

      if deposited_file_count == documents_to_deposit.size
        # All documents were successfully deposited, time to Publish
        request_deposition_publication(remote_deposition) do |publish_response|
          remote_deposition = JSON.parse(publish_response.body)
          set_submission_doi(remote_deposition)
        end
      end
    end
  end

  private

  def check_documents_presence
    return true if documents_to_deposit.present?

    report_problem 'Nothing to deposit in Zenodo - deposition documents empty.'
    false
  end

  def request_deposition(&block)
    submit_request(
      query_url,
      method: :post,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        metadata: {
          upload_type: 'dataset',
          title: @deposition.title,
          creators: @deposition.creators,
          contributors: contributors,
          description: @deposition.description,
          keywords: ['Brassica', 'Phenotyping', 'Association studies'],
          subjects: [
            { term: 'Phenotype', identifier: 'http://id.loc.gov/authorities/subjects/sh96012165' },
            { term: 'Brassica', identifier: 'http://id.loc.gov/authorities/subjects/sh86001831' },
            { term: 'Plant breeding', identifier: 'https://www.britannica.com/science/plant-breeding' }
          ],
          license: 'odc-pddl'
        }
      }.to_json,
      &block
    )
  end

  def request_file_upload(remote_deposition, file, &block)
    submit_request(
      query_url("/#{remote_deposition['id']}/files"),
      method: :post,
      headers: { 'Content-Type' => 'multipart/form-data' },
      body: {
        filename: Pathname(file.path).basename.to_s,
        file: file
      },
      &block
    )
  end

  def request_deposition_publication(remote_deposition, &block)
    submit_request(
      query_url("/#{remote_deposition['id']}/actions/publish"),
      method: :post,
      &block
    )
  end

  def documents_to_deposit
    @deposition.documents_to_deposit.select { |_, contents| contents.present? }
  end

  def contributors
    names = @deposition.contributors.lines.map(&:strip).select(&:present?)
    names.map do |contributor|
      { name: contributor, type: 'Researcher' }
    end
  end

  def write_file(contents, files_directory, filename)
    path = File.join(files_directory, filename)
    File.open(path, 'w').tap do |file|
      file.write(contents)
      file.rewind
    end
  end

  def set_submission_doi(remote_deposition)
    return unless @deposition.submission
    @deposition.submission.doi = remote_deposition['doi']
    @deposition.submission.save!
  end

  def submit_request(url, options)
    request = Typhoeus::Request.new(url, options)

    request.on_complete do |response|
      if response.success?
        yield response
      elsif response.timed_out?
        report_problem 'Zenodo service does not respond. Unable to deposit data.', true
      elsif response.code == 0
        report_problem 'Zenodo service responded with invalid content. Unable to conclude data deposition.', true
      else
        Rails.logger.tagged(self.class.name) do
          Rails.logger.info response.body
        end
        report_problem "Zenodo service responded with failure code #{response.code}. Unable to conclude data deposition.", true
      end
    end

    request.run
  end

  def query_url(resource = '')
    host = Rails.application.config_for(:zenodo)['zenodo_server']
    key = Rails.application.secrets.zenodo_key
    "#{host}api/deposit/depositions#{resource}?access_token=#{key}"
  end

  def report_problem(message, to_user = false)
    Rails.logger.tagged(self.class.name) do
      Rails.logger.warn message
    end
    @user_log << message if to_user
  end
end
