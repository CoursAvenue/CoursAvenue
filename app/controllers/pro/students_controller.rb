# encoding: utf-8
class Pro::StudentsController < Pro::ProController
  before_filter :authenticate_pro_admin!
  respond_to :js

  layout 'admin'

  authorize_resource :student

  def index
    @students = Student.order('created_at DESC').where{created_at > Date.today - 2.months}
  end

  def ask_for_feedbacks_stage_1
    @student = Student.find params[:id]
    @student.ask_for_feedbacks_stage_1
    respond_to do |format|
      format.js { render nothing: true, status: 200 }
      format.html { redirect_to pro_structure_path(@student.structure) }
    end
  end
end
