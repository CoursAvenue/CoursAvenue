class SubjectsController < ApplicationController
  respond_to :json

  def index
    @subjects = Subject.all.map(&:name)
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

end
