class GuidesController < ApplicationController
  layout 'empty'

  before_action :set_guide, only: [:show]

  def show
    @serialized_guide = GuideSerializer.new(@guide)
  end

  private

  def set_guide
    @guide = Guide.includes(:questions).find(params[:id])
  end
end
