require "rails_helper"

RSpec.describe Analysis::ShellRunner do
  let(:analysis) { create(:analysis, status: :idle) }

  before(:each) { FileUtils.rm_rf File.join(exec_dir, analysis.id.to_s) }

  describe "#call" do
    shared_examples "well behaved job" do
      it "creates unique execution directory" do
        subject.call(job_command) do
          expect(Dir.entries(exec_dir)).to include(analysis.id.to_s)
        end
      end

      it "captures STDOUT of executed command" do
        subject.call(job_command) do
          std_out = File.read File.join(exec_dir, analysis.id.to_s, 'std_out.txt')
          expect(std_out).to eq("I am alive!\n")
        end

        expect(File.read(analysis.data_files.std_out.first.file.path)).to eq("I am alive!\n")
      end

      it "captures STDERR of executed command" do
        subject.call(job_command) do
          std_err = File.read File.join(exec_dir, analysis.id.to_s, 'std_err.txt')
          expect(std_err).to eq("Hooray!\n")
        end

        expect(File.read(analysis.data_files.std_err.first.file.path)).to eq("Hooray!\n")
      end

      it "stores the PID number" do
        subject.call(job_command) do
          pid = File.read File.join(exec_dir, analysis.id.to_s, 'job.pid')
          expect(Integer(pid)).to eq(analysis.reload.associated_pid)
        end
      end
    end

    subject { described_class.new(analysis) }

    context "successful job execution" do
      let(:job_command) { "{ echo 'I am alive!'; echo 'Hooray!' >&2; }" }

      it "updates analysis status" do
        expect { subject.call(job_command) }.
          to change { analysis.reload.status }.
          from("idle").to("success")
      end

      it_behaves_like "well behaved job"

      it "cleans up execution directory" do
        subject.call(job_command)
        expect(Dir.entries(exec_dir)).not_to include(analysis.id.to_s)
      end
    end

    context "failed job execution" do
      let(:job_command) { "{ echo 'I am alive!'; echo 'Hooray!' >&2; exit 1; }" }

      it "updates analysis status" do
        expect { subject.call(job_command) }.
          to change { analysis.reload.status }.
          from("idle").to("failure")
      end

      it_behaves_like "well behaved job"

      it "preserves execution directory" do
        subject.call(job_command)
        expect(Dir.entries(exec_dir)).to include(analysis.id.to_s)
      end
    end
  end

  describe "#store_result" do
    it "appends to analysis outputs" do
      pending
      fail
    end
  end

  def exec_dir
    Rails.application.config_for(:jobs).fetch("execution_dir")
  end
end
