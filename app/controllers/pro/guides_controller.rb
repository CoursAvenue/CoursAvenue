class Pro::GuidesController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @guides = Guide.includes(:questions).all
  end
end
