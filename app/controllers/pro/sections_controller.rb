# encoding: utf-8
class Pro::SectionsController < Pro::ProController
  before_action :authenticate_pro_super_admin!

  def index
    @emailing = Emailing.find params[:id]
    @sections = @emailing.emailing_sections

    respond_to do |format|
      format.json { render json: @sections.to_json }
    end
  end
end
