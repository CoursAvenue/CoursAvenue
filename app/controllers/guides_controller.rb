class GuidesController < ApplicationController
  layout :get_layout

  before_action :set_guide

  def show
    @serialized_guide = GuideSerializer.new(@guide)
  end

  def suggestions
    @serialized_guide = GuideSerializer.new(@guide)
    @subject = Subject.find(params[:subject])
    @other_subjects = params[:other].split(',').map{|subject_id| Subject.find(subject_id) }
  end

  private

  def set_guide
    @guide = Guide.includes(questions: [ answers: [ :subjects, :question ] ]).find(params[:id])
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
