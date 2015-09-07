class Admin::AdminController < ApplicationController
  layout 'admin'

  before_action :authenticate_pro_super_admin!

end
