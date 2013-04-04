# encoding: utf-8
class Structures::CommentsController < ApplicationController

  def create
    @structure = Structure.find params[:structure_id]
    @comment   = @structure.comments.build params[:comment]
    respond_to do |format|
      if !cookies["comment_structure_#{@structure.id}"] and @comment.save
        cookies["comment_structure_#{@structure.id}"] = true
        format.html { redirect_to structure_path(@structure), notice: "Merci d'avoir laissé votre avis !" }
      elsif cookies["comment_structure_course_#{@structure.id}"]
        format.html { redirect_to structure_path(@structure), alert: "Vous ne pouvez pas poster deux commentaires sur le même établissement."}
      else
        format.html { redirect_to structure_path(@structure), alert: "Le commentaire n'a pas pu être posté. Assurez-vous d'avoir bien remplis tous les champs"}
      end
    end
  end
end
