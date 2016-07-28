# Service that deposits data in Zenodo.org
class ZenodoDepositor
  attr_accessor :user_log

  def initialize(deposition)
    @deposition = deposition
    @user_log = []
  end

  # 1. Sets up a new deposition in Zenodo, with proper metadata
  # 2. Uploads CSV data to that deposition
  # 3. Publishes that deposition (i.e. makes it available to Zenodo users)
  def call
    unless @deposition && @deposition.valid?
      report_problem 'Got nil or invalid Deposition. Unable to upload it to Zenodo.'
      return
    end

    documents_to_deposit = @deposition.documents_to_deposit
    if documents_to_deposit.empty?
      report_problem 'Nothing to deposit in Zenodo - deposition documents empty.'
      return
    end

    request = Typhoeus::Request.new(
      query_url,
      method: :post,
      headers: { 'Content-Type' => 'application/json' },
      body: {
        metadata: {
          upload_type: 'dataset',
          title: @deposition.title,
          creators: @deposition.creators,
          contributors: contributors_json,
          description: @deposition.description,
          license: 'odc-pddl'
        }
      }.to_json
    )

    submit_request(request) do |response|
      remote_deposition = JSON.parse(response.body)

      deposited_file_count = 0
      # We need a temp dir for deposition files
      Dir.mktmpdir do |files_directory|
        documents_to_deposit.each do |name, contents|
          next if contents.empty?
          request = Typhoeus::Request.new(
            query_url("/#{remote_deposition['id']}/files"),
            method: :post,
            headers: { 'Content-Type' => 'multipart/form-data' },
            body: {
              filename: "#{name}.csv",
              file: write_file(contents, files_directory, "#{name}.csv")
            }
          )
          submit_request(request) do |_|
            # Success
            deposited_file_count += 1
          end
        end
      end

      if deposited_file_count == documents_to_deposit.size
        # All documents were successfully deposited, time to Publish
        request = Typhoeus::Request.new(
          query_url("/#{remote_deposition['id']}/actions/publish"),
          method: :post
        )
        submit_request(request) do |publish_response|
          remote_deposition = JSON.parse(publish_response.body)
          if @deposition.submission
            @deposition.submission.doi = remote_deposition['doi']
            @deposition.submission.save!
          end
        end
      else
        #TODO FIXME Error management
      end
    end
  end

  private

  def contributors_json
    names = @deposition.contributors.split("\n")
    names = names.select(&:present?)
    names.map { |contributor|
      { name: contributor, type: 'Researcher' }
    }
  end

  def write_file(contents, files_directory, filename)
    file = File.open("#{files_directory}/#{filename}", 'w')
    file.write contents
    file.rewind
    file
  end

  def submit_request(request)
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
