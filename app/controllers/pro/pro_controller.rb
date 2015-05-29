class Pro::ProController < ApplicationController
  layout 'admin'

  before_action :set_sponsorship_token

  private

  # If admin was invited by another admin, he will have :sponsorship_token in session or params
  # We set it in the structure model
  #
  def set_sponsorship_token
    return if session[:sponsorship_token].blank? and params[:sponsorship_token].blank?
    if current_pro_admin and (structure = current_pro_admin.structure)
      structure.sponsorship_token = (session[:sponsorship_token] || params[:sponsorship_token])
      structure.save
      session.delete :sponsorship_token
    end
  end
end
