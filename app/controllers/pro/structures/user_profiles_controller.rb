# encoding: utf-8
class Pro::Structures::UserProfilesController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  # TODO is this correct? I kind of feel like the search is not being
  # restricted to the structure...
  def index
    params[:structure_id] = @structure.id
    @user_profiles_search = UserProfileSearch.search(params) # <-- shouldn't this be (search_params)
    @user_profiles = @user_profiles_search.results

    respond_to do |format|
      format.json { render json: @user_profiles, root: 'user_profiles', meta: { total: @user_profiles_search.total, busy: @structure.busy }}
      format.html
    end
  end

  def new
    @user_profile = @structure.user_profiles.build
  end

  def create
    @user_profile = @structure.user_profiles.build params[:user_profile]

    respond_to do |format|
      if @user_profile.save
        format.html { redirect_to pro_structure_user_profiles_path(@structure) }
      else
        format.html { render :new }
      end
    end
  end

  def update
    @user_profile = @structure.user_profiles.find params[:id]

    tags = params[:user_profile].delete(:tags)
    @structure.tag(@user_profile, with: tags, on: :tags)

    respond_to do |format|
      if @user_profile.update_attributes(params[:user_profile])
        format.json { render :json => @user_profile, status: 200 }
      else
        format.json { render :json => { :errors => @user_profile.errors.full_messages }.to_json, :status => 500 }
      end
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
