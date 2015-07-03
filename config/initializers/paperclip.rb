Paperclip::Attachment.default_options[:url] = "/system/:class/:hash.:extension"
Paperclip::Attachment.default_options[:hash_secret] =  Rails.application.secrets.paperclip_hash_secret
