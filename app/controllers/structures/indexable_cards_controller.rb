# encoding: utf-8
class Structures::IndexableCardsController < ApplicationController

  def show
    @structure           = Structure.friendly.find params[:structure_id]
    @structure_decorator = @structure.decorate
    @indexable_card      = @structure.indexable_cards.where(id: params[:id]).first
    # 301 for Google
    if @indexable_card.nil?
      redirect_to structure_path(@structure), status: 301
      return
    end
    @course              = @indexable_card.course
    @place               = @indexable_card.place.decorate

    respond_to do |format|
      format.html
    end
  end
end
