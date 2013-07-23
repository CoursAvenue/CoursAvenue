# encoding: utf-8
class Pro::Structures::StudentsController < Pro::ProController
  before_filter      :authenticate_pro_admin!
  authorize_resource :student

  def destroy
    @structure = Structure.find params[:structure_id]
    @student   = @structure.students.find params[:id]
    respond_to do |format|
      if @student.destroy
        format.html { redirect_to recommendations_pro_structure_path(@structure), notice: 'Élève supprimé'}
      else
        format.html { redirect_to recommendations_pro_structure_path(@structure), alert: "Une erreur s'est produite"}
      end
    end
  end
end
