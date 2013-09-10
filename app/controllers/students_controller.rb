# encoding: utf-8
class StudentsController < InheritedResources::Base
  actions :create

  def unsubscribe
    if student = Student.read_access_token(params[:signature])
      student.update_attribute :email_opt_in, false
      redirect_to root_url, notice: 'Vous avez bien été desinscrit de la liste.'
    else
      redirect_to root_url, notice: 'Lien invalide.'
    end
  end

  def create
    back_url = params[:student].delete(:url)
    create! do |format|
      if @student.errors.empty?
        flash[:notice] = t('students.creation_success_notice')
      else
        flash[:error] = t('students.wrong_email')
      end
      if back_url.nil?
        format.html { redirect_to root_url }
      else
        format.html { redirect_to back_url }
      end
    end
  end
end
