# encoding: utf-8
class Pro::Structures::BulkUserProfilesController < Pro::ProController before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  def create
      puts params['ids']
      puts "===============WAAAT==============="

    respond_to do |format|
      if true
        format.json { render :nothing => true }
      else
        format.html { render :new }
      end
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
