class JobBase < ActiveJob::Base
  rescue_from(StandardError, ScriptError) do |exception|
    ExceptionNotifier.notify_exception(
      exception,
      data: {
        job_id: job_id,
        queue: queue_name,
        arguments: arguments
      })

    raise exception
  end
end
