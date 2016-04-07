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

    request = Typhoeus::Request.new(query_url)

    request.on_complete do |response|
      if response.success?
        # TODO FIXME just a temporary generated DOI, implement actual Zenodo client later
        doi = '10.5194/bg-8-2917-2011'
        if @deposition.submission
          @deposition.submission.doi = doi
          @deposition.submission.save!
        end
      elsif response.timed_out?
        report_problem 'Zenodo service does not respond. Unable to deposit data.', true
      elsif response.code == 0
        report_problem 'Zenodo service responded with invalid content. Unable to conclude data deposition.', true
      else
        report_problem "Zenodo service responded with failure code #{response.code}. Unable to conclude data deposition.", true
      end
    end

    request.run
  end

  private

  def query_url
    host = Rails.application.config_for(:zenodo)['zenodo_server']
    key = Rails.application.secrets.zenodo_key
    "#{host}api/deposit/depositions?access_token=#{key}"
  end

  def report_problem(message, to_user = false)
    Rails.logger.tagged(self.class.name) do
      Rails.logger.warn message
    end
    @user_log << message if to_user
  end
end
