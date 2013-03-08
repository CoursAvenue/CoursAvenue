# encoding: utf-8
class Pro::Structures::AdminsController < Pro::ProController

  layout 'admin'

  before_filter :retrieve_structure

  def create
    @admin = ::Admin.new(params[:admin])
    respond_to do |format|
      if @admin.save
        format.html { redirect_to structure_path @structure }
      else
        format.html { render 'pro/structures/edit' }
      end
    end
  end

  # def update
  #   # @admin = ::Admin.find(params[:id])
  #   update! do |format|
  #     format.html do
  #       redirect_to structure_path @structure
  #     end
  #   end
  # end

  private
  def retrieve_structure
    @structure = ::Structure.find(params[:structure_id])
  end
end
# # encoding: utf-8
# class Pro::Structures::AdminsController < InheritedResources::Base
#   layout 'admin'

#   defaults :resource_class ::Admin
#   belongs_to :structure

#   def create
#     @structure = Structure.find(params[:structure_id])
#     # @admin = ::Admin.new
#     create! do |success, failure|
#       success.html { redirect_to structure_path @structure }
#       failure.html { render action: 'structures/edit' }
#     end
#   end

#   def update
#     # @admin = ::Admin.find(params[:id])
#     update! do |format|
#       format.html do
#         redirect_to structure_path @structure
#       end
#     end
#   end
# end
