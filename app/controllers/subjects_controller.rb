class SubjectsController < ApplicationController
  respond_to :json

  def index
    @subjects = Subject.order('name ASC').all.map{|s| {name: s.name, slug: s.slug} }
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

end
