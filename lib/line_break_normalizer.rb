class LineBreakNormalizer
  def call(filepath)
    File.open(filepath, "r") do |src|
      data = src.read

      fail Encoding::InvalidByteSequenceError unless data.valid_encoding?

      Tempfile.open("") do |dst|
        data.split(/\r\n|\r|\n/).each do |line|
          dst << "#{line}\n"
        end

        dst.flush

        FileUtils.cp(dst.path, src.path)
      end
    end
  end
end
