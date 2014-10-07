class SponsorshipsController < ApplicationController

  # GET obtenir-mon-passe-decouverte/:slug/
  def show
    @sponsor = User.where(sponsorship_slug: params[:id]).first
    @sponsorship = nil

    if @sponsor.nil?
      @sponsorship = Sponsorship.where(promo_code: params[:id]).first
      @sponsor = @sponsorship.user if @sponsorship.present?
    end

  end
end
