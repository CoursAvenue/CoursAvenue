class Profs::StructuresController < Profs::ProfsController

  layout 'users'

  def index
    @structures = Structure.all
  end

  def show
    @structure = Structure.find(params[:id])
    authorize! :edit, @structure
  end

  def new
    @structure = Structure.new
  end
end
