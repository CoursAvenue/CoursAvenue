# encoding: utf-8
class Pro::Structures::UserProfilesController < Pro::ProController
  include ApplicationHelper
  before_action :authenticate_pro_admin!
  before_action :load_structure

  layout 'admin'

  # instead of paginating, we will get all the results and
  # return their ids, as well as the 30 results that correspond
  # to the given page. This is so that we can intersect
  # the filtered results with the selected results
  def index
    page = (params[:page].to_i > 0)? params[:page].to_i : 1;

    # set the page info to get EVERYTHING
    params[:structure_id] = @structure.id
    params[:per_page]     = UserProfile::PER_PAGE_CRM
    params[:page]       ||= 1

    @user_profiles_search  = UserProfileSearch.search(params)
    @user_profiles         = @user_profiles_search.results

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

    update_tags

    respond_to do |format|
      if @user_profile.save
        format.json { render json: @user_profile }
        format.html { redirect_to pro_structure_user_profiles_path(@structure) }
      else
        format.json { render :json => { errors: @user_profile.errors.full_messages }.to_json, status: 500 }
        format.html { render :new }
      end
    end
  end

  def update
    @user_profile = @structure.user_profiles.find params[:id]

    update_tags
    respond_to do |format|
      if @user_profile.update_attributes(params[:user_profile])
        format.json { render :json => @user_profile, status: 200 }
        format.js
      else
        format.json { render :json => { :errors => @user_profile.errors.full_messages }.to_json, :status => 500 }
        format.js
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

  def import_batch_emails
    UserProfile.delay.batch_create(@structure, params[:emails], mailing_list_tag)
    respond_to do |format|
      format.html { redirect_to pro_structure_user_profiles_path(@structure), notice: "L'import est en cours, nous vous enverrons un mail dès l'import terminé." }
    end
  end

  private

  def load_structure
    @structure = Structure.friendly.find params[:structure_id]
  end

  def add_tags(tags)
    @structure.tag(@user_profile, with: tags, on: :tags)
  end

  def update_tags
    update_tags = params[:user_profile].has_key? :tags

    if update_tags
      tags = params[:user_profile].delete(:tags)
      add_tags(tags)
    end
  end
end
