# Allows to retain arbitrary filename when storing files with paperclip.
class NamedTempfile < Tempfile
  attr_accessor :original_filename
end
