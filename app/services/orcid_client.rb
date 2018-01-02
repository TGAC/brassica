# Service to implement ORCiD client API
# Currently it simply retrieves user's public info from ORCiD
class OrcidClient
  def self.get_user_data(uid)
    orcid_config = Rails.application.config_for(:orcid)
    begin
      uri = URI(orcid_config['client_options']['site'] + '/' + uid)
      info_xml = Nokogiri::XML(Net::HTTP.get(uri))
      error_desc = info_xml.at_css('error-desc')
      raise Exception.new(error_desc.content) if error_desc
    rescue Exception => e
      message = "Problem accessing public ORCiD API for uid #{uid}."
      message += " Reason: \"#{e.message}\"."
      message += ' No public user information available for the moment.'
      Rails.logger.warn "WARNING: #{message}"
      return { status: :error, message: message }
    end
    given_names = info_xml.at_css('given-names')
    full_name = given_names ? given_names.content : ''
    family_name = info_xml.at_css('family-name')
    full_name += ' ' + family_name.content if family_name
    full_name = info_xml.at_css('full-name') if full_name.blank?
    { status: :ok, full_name: full_name }
  end
end
