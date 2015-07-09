# encoding: utf-8
class Structures::IndexableCardsController < ApplicationController

  def show
    @structure      = Structure.friendly.find params[:structure_id]
    @indexable_card = @structure.indexable_cards.find params[:id]
    @course         = @indexable_card.course
    @place          = @indexable_card.place.decorate

    respond_to do |format|
      format.html
    end
  end
end
