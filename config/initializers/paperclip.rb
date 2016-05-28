Paperclip::Attachment.default_options[:url] = "/system/:class/:hash.:extension"
Paperclip::Attachment.default_options[:hash_secret] =  Rails.application.secrets.paperclip_hash_secret

require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end
