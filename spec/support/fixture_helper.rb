module FixtureHelper
  def fixture_file(path, content_type)
    fixture_file_upload(File.join("files", path), content_type)
  end
end
