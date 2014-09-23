# encoding: utf-8
class Pro::EmailingsController < Pro::ProController
  before_action :authenticate_pro_super_admin!
  layout 'admin'

  def index
    @emailings = Emailing.all
  end

  def new
    @emailing = Emailing.new
  end

  def show
    @emailing = Emailing.find params[:id]
  end

  def create
    @emailing = Emailing.new params[:emailing]

    respond_to do |format|
      if @emailing.save
        format.html { redirect_to pro_emailing_path, notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def edit
    @emailing = Emailing.find params[:id]

    count = 3 - @emailing.emailing_sections.count
    count.times { @emailing.emailing_sections.build  }
  end

  def update
    @emailing = Emailing.find params[:id]

    respond_to do |format|
      if @emailing.update_attributes params[:emailing]
        format.html { redirect_to pro_emailing_path, notice: 'Bien enregistré' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @emailing = Emailing.new params[:id]

    respond_to do |format|
      if @emailing.destroy
        format.html { redirect_to pro_emailing_path, notice: 'Supprimé' }
      else
        format.html { redirect_to pro_emailing_path, notice: 'Il y eu un problème' }
      end
    end
  end

end
