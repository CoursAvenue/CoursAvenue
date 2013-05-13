# encoding: utf-8
class Pro::Structures::CommentsController < InheritedResources::Base#Pro::ProController
  before_filter :authenticate_pro_admin!
  layout 'admin'

  def index
    @structure = Structure.find params[:structure_id]
    unless can? :read, @structure
      redirect_to pro_root_path, alert: "Vous n'êtes pas autorisé à voir cette page."
    end
    @structure_comments = @structure.comments

    @courses_comments = {}
    @structure.courses.each do |course|
      @courses_comments[course] = course.comments if course.comments.any?
    end
  end
end
