Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 14.days
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', "job-#{Rails.env}.log"))
