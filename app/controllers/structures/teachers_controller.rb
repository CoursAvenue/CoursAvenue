# encoding: utf-8
class Structures::TeachersController < InheritedResources::Base

  belongs_to :structure

  def index
    @teacher   = Teacher.new
    @structure = Structure.friendly.find params[:structure_id]
    @teachers  = @structure.teachers.order('name ASC')

    respond_to do |format|
      format.json { render json: @teachers, root: false, each_serializer: TeacherSerializer }
    end
  end
end
