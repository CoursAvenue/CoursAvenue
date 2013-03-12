class Pro::StructuresController < Pro::ProController
  #before_filter :authenticate_admin!
  layout 'admin'

  def index
    authorize! :manage, Structure
    @structures = Structure.order('name ASC').all
  end

  def show
    @structure = Structure.find params[:id]
    @courses   = @structure.courses
  end

  def edit
    @structure = Structure.find(params[:id])
    authorize! :edit, @structure
    @admin     = @structure.admins.first || Admin.new
  end

  def new
    @structure = Structure.new
  end

  def update
    @structure = Structure.find params[:id]
    authorize! :manage, @structure

    @admin     = @structure.admins.first || Admin.new

    respond_to do |format|
      if @structure.update_attributes params[:structure]
        format.html { redirect_to edit_structure_path @structure }
      else
        format.html { render action: 'edit' }
      end
    end
  end
end
