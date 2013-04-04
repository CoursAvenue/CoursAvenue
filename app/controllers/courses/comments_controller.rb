# encoding: utf-8
class Courses::CommentsController < ApplicationController

  def create
    @course  = Course.find params[:course_id]
    @comment = @course.comments.build params[:comment]
    respond_to do |format|
      if @comment.save
        format.html { redirect_to course_path(@course), notice: "Merci d'avoir laissé votre avis !" }
      else
        format.html { redirect_to course_path(@course), alert: "Le commentaire n'a pu être posté. Assurez-vous d'avoir bien remplis tous les champs"}
      end
    end
  end
end
