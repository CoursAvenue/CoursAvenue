class Pro::ProController < ApplicationController
  layout 'admin'

  def authenticate_pro_super_admin!
    unless current_pro_admin.super_admin?
      redirect_to root_path, alert: "Vous n'avez pas le droit !"
    end
  end

end
