module Submissions
  module Trial
    class Step04ContentForm < PlantTrialForm
      property :layout_upload_id
      property :visibility, default: 'published'
      property :data_owned_by
      property :data_provenance
      property :comments

      validates :visibility, inclusion: { in: %w(published private) }

      def layout_upload
        Submission::Upload.plant_trial_layout.find_by(id: layout_upload_id)
      end
    end
  end
end
