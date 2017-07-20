class LineBreakNormalizer
  def call(filepath)
    File.open(filepath, "r") do |src|
      Tempfile.open("") do |dst|
        src.each_line do |line|
          dst << line.sub(/\r\n|\r/, "\n")
        end

        dst.flush

        FileUtils.cp(dst.path, src.path)
      end
    end
  end
end
