class Pro::ProController < ApplicationController
  layout 'admin'
  helper OnboardingHelper

  before_action :authenticate_pro_admin!
  before_action :load_structure

  authorize_resource :structure

  private

  def load_structure
    if params[:id] == '_REPLACE_THIS_' and current_pro_admin.present?
      params[:id] = current_pro_admin.structure.slug
    end
    @structure = Structure.friendly.find(params[:id]) if params[:id].present?
  end
end
