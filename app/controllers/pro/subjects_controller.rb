# encoding: utf-8
class Pro::SubjectsController < Pro::ProController
  before_filter :authenticate_pro_admin!
  before_filter :authenticate_pro_super_admin

  def index
    @subjects = Subject.all
  end

  def edit
    @subject = Subject.find params[:id]
  end

  def update
    @subject = Subject.find params[:id]
    respond_to do |format|
      if @subject.update_attributes params[:subject]
        format.html { redirect_to pro_subjects_path}
      else
        format.html { render action: :edit }
      end
    end
  end

  private
  def authenticate_pro_super_admin
    unless can? :edit, Admin
      redirect_to root_path, alert: "Vous n'avez pas le droit !"
    end
  end
end
