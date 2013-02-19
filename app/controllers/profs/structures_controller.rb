class Profs::StructuresController < ApplicationController

  def index
    @structures = Structure.all
  end

  def show
    @structure = Structure.find(params[:id])
    authorize! :edit, @structure
  end

end
