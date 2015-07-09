class GuidesController < ApplicationController
  layout 'empty'

  before_action :set_guide, only: [:show]

  def show
  end

  private

  def set_guide
    @guide = Guide.includes(:questions, :answers).find(params[:id])
  end
end
