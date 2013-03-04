class Pro::ProController < ApplicationController
  layout 'admin'

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end

end
