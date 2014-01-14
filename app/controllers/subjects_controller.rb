class SubjectsController < ApplicationController
  respond_to :json

  def show
    @france_center_lat = 46.76844
    @france_center_lng = 2.432613
    @subject = Subject.find params[:id]

    if @subject.depth == 1
      to_merge = { subject_slugs: @subject.children.map(&:slug) }
    else
      to_merge = { subject_id: @subject.slug }
    end

    @structure_search            = StructureSearch.search({lat: @france_center_lat, lng: @france_center_lng, radius: 500, per_page: 20, bbox: true}.merge(to_merge))
    @location_search             = LocationSearch.search({lat: @france_center_lat, lng: @france_center_lng, radius: 500, per_page: 80, bbox: true}.merge(to_merge))
    @planning_search             = PlanningSearch.search({lat: @france_center_lat, lng: @france_center_lng, radius: 500, per_page: 1, bbox: true}.merge(to_merge))
    @free_trial_plannings_search = PlanningSearch.search({lat: @france_center_lat, lng: @france_center_lng, radius: 500, per_page: 1, bbox: true, trial_course_amount: 0}.merge(to_merge))
    @medias_search               = MediaSearch.search({lat: @france_center_lat, lng: @france_center_lng, radius: 500, per_page: 1, bbox: true}.merge(to_merge))
    @images_search               = MediaSearch.search({lat: @france_center_lat, lng: @france_center_lng, radius: 500, per_page: 25, type: 'Media::Image', bbox: true}.merge(to_merge))
    @comments_search             = CommentSearch.search({lat: @france_center_lat, lng: @france_center_lng, radius: 500, per_page: 25, has_title: true, bbox: true}.merge(to_merge))
    @courses_search              = CourseSearch.search({lat: @france_center_lat, lng: @france_center_lng, radius: 500, per_page: 20, has_description: true, bbox: true}.merge(to_merge))

    if @subject.depth > 1
      @videos_search            = MediaSearch.search({lat: @france_center_lat, lng: @france_center_lng, radius: 500, per_page: 5, type: 'Media::Video', bbox: true}.merge(to_merge))
      @videos                   = @videos_search.results
    end

    @structures               = @structure_search.results
    @images                   = @images_search.results
    @courses                  = @courses_search.results
    @comments                 = @comments_search.results

    @structures_count         = @structure_search.total
    @places_count             = @location_search.total
    @plannings_count          = @planning_search.total
    @free_trial_course_count  = @free_trial_plannings_search.total
    @comments_count           = @comments_search.total
    @medias_count             = @medias_search.total

    @json_structure_addresses = Gmaps4rails.build_markers(@location_search.results) do |location, marker|
      marker.lat location.latitude
      marker.lng location.longitude
    end
  end

  def index
    @subjects = Subject.order('name ASC').all.map{|s| {name: s.name, slug: s.slug} }
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

  # Params:
  #    ids: subject ids separeted by comas (123,124,53)
  #  Returns json:
  #     Danse - Danse de salon :
  #           - Salsa
  #           - Zumba
  #           - ...
  #     Cuisine - ...:
  #           - ...
  def descendants
    @subjects = params[:ids].split(',').map{ |id| Subject.friendly.find(id) }
    @descendants = []
    @subjects.each do |parent_subject|
      parent_subject.descendants.at_depth(1).each do |first_descendant|
        obj                = {}
        parent_name        = first_descendant.name
        obj[parent_name] ||= []
        first_descendant.children.order('name ASC').each do |second_descendant|
          obj[parent_name] << second_descendant
        end
        @descendants << obj
      end
    end
    @descendants = @descendants.sort_by{|subj| subj.keys[0]}
    respond_to do |format|
      if params[:callback]
        format.js { render :json => {descendants: @descendants.to_json}, callback: params[:callback] }
      else
        format.json { render json: @descendants.to_json }
      end
    end
  end

  def tree
    if params[:parent]
      subject_roots = [Subject.friendly.find(params[:parent])]
    else
      subject_roots = Subject.roots
    end
    @subjects = {}
    subject_roots.each do |root|
      @subjects[root.name] = {}
      root.children.each do |sub_root|
        @subjects[root.name][sub_root.name] = []
        sub_root.children.each do |sub_sub_root|
          @subjects[root.name][sub_root.name] << sub_sub_root.name
        end
      end
    end
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end

  def tree_2
    if params[:parent]
      subject_roots = [Subject.friendly.find(params[:parent])]
    else
      subject_roots = Subject.roots
    end
    @subjects = {}
    subject_roots.each do |root|
      @subjects["#{root.name} - #{root.slug} (#{root.courses.count})"] = {}
      root.children.each do |sub_root|
        @subjects["#{root.name} - #{root.slug} (#{root.courses.count})"]["#{sub_root.name} - #{sub_root.slug} (#{sub_root.courses.count})"] = []
        sub_root.children.each do |sub_sub_root|
          @subjects["#{root.name} - #{root.slug} (#{root.courses.count})"]["#{sub_root.name} - #{sub_root.slug} (#{sub_root.courses.count})"] << "#{sub_sub_root.name} - #{sub_sub_root.slug} (#{sub_sub_root.courses.count})"
        end
      end
    end
    respond_to do |format|
      format.json { render json: @subjects.to_json }
    end
  end
end
