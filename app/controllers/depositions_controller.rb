class DepositionsController < ApplicationController

  before_filter :authenticate_user!

  def new
    @deposition = Deposition.new(submission: submission, user: current_user)
  end

  def create
    @deposition = Deposition.new(deposition_create_params)

    if @deposition.valid?
      service = ZenodoDepositor.new(@deposition)
      service.call
      if @deposition.submission
        if @deposition.submission.doi
          redirect_to @deposition.submission,
                      notice: "Assigned DOI number: #{@deposition.submission.doi}."
        else
          redirect_to @deposition.submission,
                      alert: service.user_log.join('\n')
        end
      else
        #TODO FIXME temporary, before we (TG and WJ) decide how to handle data table Zenodo deposition
        redirect_to browse_data_path
      end
    else
      render :new
    end
  end

  private

  def submission
    if params[:deposition][:submission_id]
      current_user.submissions.find(params[:deposition].delete(:submission_id))
    end
  end

  def deposition_create_params
    params.fetch(:deposition, {}).permit(
      :title,
      :description,
      :contributors
    ).merge(
      submission: submission,
      user: current_user
    )
  end
end
