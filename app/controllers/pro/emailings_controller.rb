# encoding: utf-8
class Pro::EmailingsController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
  end

  def new
  end

  def create
  end

end
