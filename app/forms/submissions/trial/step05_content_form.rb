module Submissions
  module Trial
    class Step05ContentForm < PlantTrialForm
      property :layout_upload_id

      def layout_upload
        Submission::Upload.plant_trial_layout.find_by(id: layout_upload_id)
      end
    end
  end
end
