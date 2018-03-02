module Submissions
  module Trial
    class Step06ContentForm < PlantTrialForm
      property :treatment_upload_id

      def treatment_upload
        upload = Submission::Upload.plant_trial_treatment.find_by(id: treatment_upload_id)
        SubmissionPlantTrialTreatmentUploadDecorator.decorate(upload) if upload
      end
    end
  end
end
