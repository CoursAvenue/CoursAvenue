# encoding: utf-8
class Pro::Structures::UserProfilesController < Pro::ProController
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  def index
    params[:structure_id] = @structure.id
    @user_profiles_search = UserProfileSearch.search(params)
    @user_profiles = @user_profiles_search.results

    # TODO this is probably a bad idea
    if @structure.busy == "true" && Delayed::Job.count == 0
        @structure.busy = "false"
        @structure.save # we somehow got out of sync
    end

    respond_to do |format|
      format.json { render json: @user_profiles, root: 'user_profiles', meta: { total: @user_profiles_search.total, busy: @structure.busy }}
      format.html
    end
  end

  def edit
    @user_profile = UserProfile.find(params[:id])

    respond_to do |format|
      if request.xhr?
        format.html {render layout: false}
      else
        format.json {render json: @user_profile }
      end
    end
  end

  def new
    @user_profile = @structure.user_profiles.build
  end

  def create
    @user_profile = @structure.user_profiles.build params[:user_profile]

    respond_to do |format|
      if @user_profile.save
        format.json { render json: @user_profile.to_json }
        format.html { redirect_to pro_structure_user_profiles_path(@structure) }
      else
        format.html { render :new }
      end
    end
  end

  def update
    @user_profile = @structure.user_profiles.find params[:id]

    if params[:user_profile].has_key? :tags
      # TODO does this take an array, or a CSV
      tags = params[:user_profile].delete(:tags)
      @structure.tag(@user_profile, with: tags, on: :tags)
    end

    respond_to do |format|
      if @user_profile.update_attributes(params[:user_profile])
        format.json { render :json => @user_profile, status: 200 }
      else
        format.json { render :json => { :errors => @user_profile.errors.full_messages }.to_json, :status => 500 }
      end
    end
  end

  def destroy
    @user_profile = @structure.user_profiles.find params[:id]

    respond_to do |format|
        if @user_profile.destroy

            format.json { render :json => @user_profile }
        end
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end
end
