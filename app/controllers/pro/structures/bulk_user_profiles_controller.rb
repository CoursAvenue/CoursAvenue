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

  # a "new" BulkUserProfile is an array of ids matching given search
  # params
  # new corresponds to the "deepSelect" method on the client
  def new
    params[:structure_id] = @structure.id
    params[:per_page]     = @structure.user_profiles.count

    # prepare all the profiles that would match the given params
    @user_profiles_search = UserProfileSearch.search(params)
    @user_profiles = @user_profiles_search.results

    respond_to do |format|
      format.json { render json: { ids: @user_profiles.map(&:id) }}
      format.html
    end
  end

  # from an array of ids, we create a delayed job that works on the
  # profiles associated with those ids
  def create
    tags = params.delete(:tags)

    if params.has_key? :ids and not params[:ids].nil?
      @user_profiles = UserProfile.where(id: params[:ids])
    else
      @user_profiles = UserProfile.all
    end

    @structure.busy = true
    @structure.perform_bulk_user_profiles_job(@user_profiles.map(&:id), :add_tags_on, tags)

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
