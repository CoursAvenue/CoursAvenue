class GuidesController < ApplicationController
  layout 'empty'

  before_action :set_guide, only: [:show]

  def show
    @serialized_guide = GuideSerializer.new(@guide)
  end

  private

  def set_guide
    @guide = Guide.includes(questions: [ answers: [ :subjects, :question ] ]).find(params[:id])
  end
  def layout_locals
    { hide_header: true }
  end
end
