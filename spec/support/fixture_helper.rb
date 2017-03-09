module FixtureHelper
  def fixture_file(path, content_type)
    fixture_file_upload(File.join("files", path), content_type)
  end

  def fixture_file_path(file_path)
    File.join(fixture_path, "files", file_path)
  end
end
