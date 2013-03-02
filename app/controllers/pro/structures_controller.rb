class Pro::StructuresController < Pro::ProController

  layout 'admin'

  def index
    @structures = Structure.all
  end

  def show
    @structure = Structure.find(params[:id])
    # authorize! :edit, @structure
  end

  def new
    @structure = Structure.new
  end

  def create
    @structure = Structure.create params[:structure]
    redirect_to profs_structure_path(@structure)
  end
end
