# encoding: utf-8
class Courses::CommentsController < ApplicationController

  def create
    @course  = Course.find params[:course_id]
    @comment = @course.comments.build params[:comment]
    respond_to do |format|
      if !cookies["comment_course_#{@course.id}"] and @comment.save
        cookies["comment_course_#{@course.id}"] = true
        format.html { redirect_to course_path(@course), notice: "Merci d'avoir laissé votre avis !" }
      elsif cookies["comment_course_#{@course.id}"]
        format.html { redirect_to course_path(@course), alert: "Vous ne pouvez pas poster deux commentaires sur le même cours."}
      else
        format.html { redirect_to course_path(@course), alert: "Le commentaire n'a pas pu être posté. Assurez-vous d'avoir bien remplis tous les champs."}
      end
    end
  end
end
