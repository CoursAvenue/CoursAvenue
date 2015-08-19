class GuidesController < ApplicationController
  layout :get_layout

  before_action :set_guide

  def show
    @serialized_guide = GuideSerializer.new(@guide)
  end

  # @params other: like subject_id;score,subject_id;score
  def suggestions
    @serialized_guide = GuideSerializer.new(@guide)
    @subject = Subject.find(params[:subject].split(';').first)
    if params[:other]
      @other_subjects = params[:other].split(',').map do |subject_id_score|
        subject_id, score = subject_id_score.split(';')
        [Subject.find(subject_id), score]
      end
    end
  end

  private

  def set_guide
    @guide = Guide.find(params[:id])
  end

  def layout_locals
    { hide_header: true }
  end

  def get_layout
    if action_name == 'suggestions'
      'pages'
    else
      'empty'
    end
  end

end
