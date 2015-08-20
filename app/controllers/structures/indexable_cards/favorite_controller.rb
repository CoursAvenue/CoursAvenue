class Structures::IndexableCards::FavoriteController < ApplicationController
  before_filter :set_structure_and_card

  def create
    if current_user.present? and @indexable_card.present?
      favorite = current_user.favorites.where(indexable_card_id: @indexable_card.id).first ||
	current_user.favorites.create(indexable_card: @indexable_card)
    else
      favorite = nil
    end

    respond_to do |format|
      if favorite.present?
	format.json { render json: { id: @indexable_card.slug }, status: :created }
      else
	format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if current_user.present? and @indexable_card.present?
      favorite = current_user.favorites.where(indexable_card_id: @indexable_card.id).first
      favorite.destroy if favorite.present?
      deleted = true
    else
      deleted = false
    end

    respond_to do |format|
      if deleted
	format.json { render json: { deleted: true }, status: :ok }
      else
	format.json { render json: {}, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_structure_and_card
    @structure           = Structure.friendly.find params[:structure_id]
    @indexable_card      = @structure.indexable_cards.includes(:place, :course).where(
      IndexableCard.arel_table[:slug].eq(params[:indexable_card_id]).
      or(IndexableCard.arel_table[:id].eq(params[:indexable_card_id]))
    ).first
  end
end
