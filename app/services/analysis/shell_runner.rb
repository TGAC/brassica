class Analysis::ShellRunner
  JobError = Class.new(RuntimeError)

  def initialize(analysis)
    @analysis = analysis
  end

  # Run job in the shell, job command MUST be properly escaped.
  def call(job_command)
    raise "Invalid analysis status" unless analysis.idle?

    set_status :running
    setup_exec_dir
    run_job_command(job_command)
    set_status :success
    yield if block_given?
    remove_exec_dir
  rescue JobError
    set_status :failure, :shell_job_error
  rescue
    set_status :failure
    raise
  end

  def exec_dir
    @exec_dir ||= File.join(
      Rails.application.config_for(:jobs).fetch('execution_dir'),
      analysis.id.to_s
    )
  end

  def store_result(file_name, data_type:)
    path = File.join(exec_dir, "results", file_name)
    store_file(path, data_type: data_type)
  end

  def results_dir
    @results_dir ||= File.join(exec_dir, "results")
  end

  def mark_as_failure(reason = nil)
    set_status(:failure, reason)
  end

  private

  attr_reader :analysis

  def set_status(new_status, reason = nil)
    analysis.status = new_status
    analysis.meta['failure_reason'] = reason
    analysis.finished_at = Time.now if analysis.finished?
    analysis.save!
  end

  def run_job_command(job_command)
    job_command = "cd #{exec_dir}; #{job_command}"

    logger.info "Executing following command line: #{job_command}"

    # Start job in another process, capturing both output streams
    IO.popen(job_command + " 2>>#{std_err_path} 1>>#{std_out_path}", 'r+') do |child_io|
      # Record job process pid in both a file and the DB, for convenience
      `echo #{child_io.pid} >> #{File.join(exec_dir, 'job.pid')}`
      analysis.update(associated_pid: child_io.pid)

      child_io.gets until child_io.eof?
    end

    logger.info "Finished shell job execution, exit code: (#{$?})."

    raise(JobError, "ERROR in processing: (#{$?})") unless $?.success?

  ensure
    store_file(std_out_path, data_type: :std_out)
    store_file(std_err_path, data_type: :std_err)
  end

  def store_file(path, data_type:)
    File.open(path, "r") do |file|
      analysis.data_files.create!(owner: analysis.owner, role: :output, origin: :generated,
                                  file: file, data_type: data_type)
    end
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

  def logger
    Rails.logger
  end
end
