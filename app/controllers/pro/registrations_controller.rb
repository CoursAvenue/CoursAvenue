class Pro::RegistrationsController < Pro::ProController
  layout 'home'

  def new
    @structure = Structure.new
  end

  def create
  end
end
