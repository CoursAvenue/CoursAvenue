# encoding: utf-8
class Places::CommentsController < ApplicationController

  def create
    @place = Place.find params[:place_id]
    @comment   = @place.comments.build params[:comment]
    respond_to do |format|
      if !cookies["comment_structure_#{@place.id}"] and @comment.save
        cookies["comment_structure_#{@place.id}"] = true
        format.html { redirect_to place_path(@place), notice: "Merci d'avoir laissé votre avis !" }
      elsif cookies["comment_structure_#{@place.id}"]
        format.html { redirect_to place_path(@place), alert: "Vous ne pouvez pas poster deux commentaires sur le même lieu."}
      else
        format.html { redirect_to place_path(@place), alert: "Le commentaire n'a pas pu être posté. Assurez-vous d'avoir bien remplis tous les champs"}
      end
    end
  end
end
