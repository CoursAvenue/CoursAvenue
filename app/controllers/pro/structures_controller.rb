class Pro::StructuresController < Pro::ProController
  #before_filter :authenticate_admin_user!
  layout 'admin'

  def index
    authorize! :manage, Structure
    @structures = Structure.all
  end

  def show
    @structure = Structure.find params[:id]
    redirect_to edit_structure_path(@structure)
  end

  def edit
    @structure = Structure.find(params[:id])
    authorize! :edit, @structure
    @admin     = @structure.admin_users.first || AdminUser.new
  end

  def new
    @structure = Structure.new
  end

  def update
    @structure = Structure.find params[:id]
    authorize! :manage, @structure
    @admin     = @structure.admin_users.first || AdminUser.new
    @structure.update_attributes params[:structure]
    respond_to do |format|
      format.html { render action: 'edit' }
    end
  end
end
