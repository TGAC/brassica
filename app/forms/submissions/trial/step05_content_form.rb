module Submissions
  module Trial
    class Step05ContentForm < PlantTrialForm
      property :environment_upload_id

      def environment_upload
        upload = Submission::Upload.plant_trial_environment.find_by(id: environment_upload_id)
        SubmissionPlantTrialEnvironmentUploadDecorator.decorate(upload) if upload
      end
    end
  end
end
