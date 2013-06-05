class StudentsController < InheritedResources::Base
  actions :create

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
