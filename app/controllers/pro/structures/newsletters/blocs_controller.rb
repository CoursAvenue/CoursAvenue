class Pro::Structures::Newsletters::BlocsController < ApplicationController
  before_action :authenticate_pro_admin!
  before_action :set_structure_and_newsletter

  def create
    @bloc = @newsletter.blocs.new permitted_params

    respond_to do |format|
      if @bloc.save
        format.json { render json: @bloc, status: 201 }
      else
        format.json { render json: { errors: @bloc.errors.full_messages }, status: 422 }
      end
    end
  end

  def update
    @bloc = @newsletter.blocs.find params[:id]

    respond_to do |format|
      if @bloc.update_attributes permitted_params
        format.json { render json: @bloc, status: 201 }
      else
        format.json { render json: { errors: @bloc.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @bloc = @newsletter.blocs.find params[:id]

    respond_to do |format|
      if @bloc.destroy
        format.json { render nothing: true, status: 204 }
      else
        format.json { render nothing: true, status: 422 }
      end
    end
  end

  private

  def set_structure_and_newsletter
    @structure  = Structure.find(params[:structure_id])
    @newsletter = @structure.newsletters.find(params[:newsletter_id])
  end

  def permitted_params
    params.require(:bloc).permit(:position, :type, :content, :remote_image_url)
  end
end
