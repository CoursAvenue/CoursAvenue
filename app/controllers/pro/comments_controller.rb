# encoding: utf-8
class Pro::CommentsController < InheritedResources::Base#Pro::ProController
  layout 'admin'

  def index
    @structure = Structure.find params[:structure_id]
    @places_comments = {}
    @structure.places.each do |place|
      @places_comments[place] = place.comments if place.comments.any?
    end
    @courses_comments = {}
    @structure.courses.each do |course|
      @courses_comments[course] = course.comments if course.comments.any?
    end
  end
end
