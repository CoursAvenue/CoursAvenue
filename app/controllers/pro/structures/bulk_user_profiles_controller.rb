# encoding: utf-8
class Pro::Structures::BulkUserProfilesController < Pro::ProController
  attr_accessor :working
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  def index

    respond_to do |format|
      format.json { render json: { busy: (@structure.busy == "true")? true : false } }
    end
  end

  def create
    tags = params.delete(:tags)

    if params.has_key? :ids and not params[:ids].nil?
      @user_profiles = UserProfile.where(id: params[:ids])
    else
      @user_profiles = UserProfile.all
    end

    @structure.busy = true
    @structure.perform_bulk_user_profiles_job(@user_profiles.map(&:id), :bulk_tagging, tags)

    respond_to do |format|
      format.json { render :nothing => true }
      format.html { render :new }
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
