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
    @course = @indexable_card.course
    if @indexable_card.place.present?
      @place = @indexable_card.place.decorate
      @city  = @place.city
    end
    @serialized_structure = StructureSerializer.new(@structure)
    @card_redux = {
      id:       @indexable_card.id,
      slug:     @indexable_card.slug,
      subjects: @indexable_card.subjects.pluck(:slug),
      position: { lat: @indexable_card.place_latitude, lng: @indexable_card.place_longitude }
    }

    if current_user
      @favorited = current_user.favorites.cards.where(indexable_card_id: @indexable_card.id).present?
    else
      @favorited = false
    end

    respond_to do |format|
      format.html
      format.json { render json: @indexable_card, serializer: IndexableCardSerializer }
    end
  end

  private

  def set_structure_and_card
    @structure           = Structure.includes(places: [:city]).friendly.find(params[:structure_id])
    @indexable_card      = @structure.indexable_cards.includes(:place, :course).where(IndexableCard.arel_table[:slug].eq(params[:id]).or(IndexableCard.arel_table[:id].eq(params[:id]))).first
  end
end
