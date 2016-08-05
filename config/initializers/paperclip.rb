Paperclip::Attachment.default_options[:url] = "/system/:class/:hash.:extension"
Paperclip::Attachment.default_options[:hash_secret] =  Rails.application.secrets.paperclip_hash_secret

Paperclip.options[:content_type_mappings] = {
  csv: %w(application/vnd.ms-excel text/plain text/csv),
  txt: %w(application/vnd.ms-excel text/plain text/csv)
}
