class Pro::RedirectController < ApplicationController

  def structures_new
    redirect_to inscription_pro_structures_path(params_for_search), status: 301
  end

  private
  def params_for_search
    params.delete(:action)
    params.delete(:controller)
    params
  end
end
