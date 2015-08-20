# encoding: utf-8
class Structures::IndexableCardsController < ApplicationController

  before_action :set_structure_and_card

  # GET /etablissements
  # GET /paris
  # GET /danse--paris
  # GET /danse/danse-orientale--paris
  def show
    @structure_decorator = @structure.decorate
    # 301 for Google
    if @indexable_card.nil?
      redirect_to structure_path(@structure), status: 301
      return
    end
    @course              = @indexable_card.course
    @place               = @indexable_card.place.decorate

    respond_to do |format|
      format.html
      format.json { render json: @indexable_card, serializer: IndexableCardSerializer }
    end
  end

  # POST /favorite
  def toggle_favorite
    if current_user
      @indexable_card.toggle_favorite!(current_user)
    end

    respond_to do |format|
      format.html { redirect_to structure_indexable_card_path(@structure, @indexable_card) }
      format.json { render json: {}, status: :ok  }
    end
  end

  private

  def set_structure_and_card
    @structure           = Structure.friendly.find params[:structure_id]
    @indexable_card      = @structure.indexable_cards.includes(:place, :course).where(IndexableCard.arel_table[:slug].eq(params[:id]).or(IndexableCard.arel_table[:id].eq(params[:id]))).first
  end
end
