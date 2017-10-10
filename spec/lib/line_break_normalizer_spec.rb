require "rails_helper"

RSpec.describe LineBreakNormalizer do
  let(:cr_file) { fixture_file("text-cr.txt", "text/plain") }
  let(:crlf_file) { fixture_file("text-crlf.txt", "text/plain") }
  let(:lf_file) { fixture_file("text-lf.txt", "text/plain") }

  let!(:lf_text) { File.read(lf_file.path) }

  it 'handles CR line endings' do
    subject.call(cr_file.path)

    expect(File.read(cr_file.path)).to eq(lf_text)
  end

  it 'handles CRLF line endings' do
    subject.call(crlf_file.path)

    expect(File.read(crlf_file.path)).to eq(lf_text)
  end

  it 'handles LF line endings' do
    subject.call(lf_file.path)

    expect(File.read(lf_file.path)).to eq(lf_text)
  end
end
