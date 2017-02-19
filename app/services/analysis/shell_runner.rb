class Analysis::ShellRunner
  JobError = Class.new(RuntimeError)

  # TODO: aborting analysis in progress

  def initialize(analysis)
    @analysis = analysis
  end

  def call(job_command)
    raise "Invalid analysis status" unless analysis.idle?

    set_status :running
    setup_exec_dir
    run_job_command(job_command)
    set_status :success
    yield if block_given?
    remove_exec_dir
  rescue JobError
    set_status :failure
  rescue
    set_status :failure
    raise
  end

  def store_result(file_name, data_type:)
    path = File.join(exec_dir, "results", file_name)
    store_file(path, data_type: data_type)
  end

  def results_dir
    @results_dir ||= File.join(exec_dir, "results")
  end

  private

  attr_reader :analysis

  def set_status(new_status)
    analysis.update!(status: new_status)
  end

  def run_job_command(job_command)
    # log 'Executing following command line'
    # log job_command

    # if reference.reload.to_be_destroyed?
    #   log "Skipping shell job execution, reference was scheduled to be destroyed."
    #   raise JobError, "Reference was scheduled to be destroyed"
    # end

    # Start job in another process, capturing both output streams
    IO.popen(job_command + " 2>>#{std_err_path} 1>>#{std_out_path}", 'r+') do |child_io|
      # Record job process pid in both a file and the DB, for convenience
      `echo #{child_io.pid} >> #{File.join(exec_dir, 'job.pid')}`
      analysis.update(associated_pid: child_io.pid)

      child_io.gets until child_io.eof?
    end

    # log "Finished shell job execution done, final exit code: (#{$?})."
    raise(JobError, "ERROR in processing: (#{$?})") unless $?.success?

  ensure
    store_file(std_out_path, data_type: :std_out)
    store_file(std_err_path, data_type: :std_err)
  end

  def store_file(path, data_type:)
    file = File.open(path, "r")
    analysis.data_files.create!(owner: analysis.owner, role: :output,
                                file: file, data_type: data_type)
  ensure
    file && file.close
  end

  def setup_exec_dir
    FileUtils.mkdir_p(exec_dir)
    FileUtils.mkdir_p(results_dir)
  end

  def remove_exec_dir
    FileUtils.remove_dir(exec_dir, true)
  end

  def std_err_path
    File.join(exec_dir, 'std_err.txt')
  end

  def std_out_path
    File.join(exec_dir, 'std_out.txt')
  end

  def exec_dir
    @exec_dir ||= File.join(
      Rails.application.config_for(:jobs).fetch('execution_dir'),
      analysis.id.to_s
    )
  end
end
