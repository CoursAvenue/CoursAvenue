class PlacesController < ApplicationController

  before_filter :prepare_search

  def show
    @place     = Place.find params[:id]
    @structure = @place.structure
    @courses   = @place.course_with_planning
    @comment   = @place.comments.build
    @comments  = @place.comments.order('created_at DESC').reject(&:new_record?)
    @city      = @place.city

    @json_place_address = @place.to_gmaps4rails do |place, marker|
      marker.title   place.name
      marker.json({ id: place.id })
    end

  end
  def index
    if @city.nil?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "La ville que vous recherchez n'existe pas" }
      end
    else
      cookies[:place_search_path] = request.fullpath
      city       = @city
      if params[:subject_id]
        @subject = Subject.find params[:subject_id]
      end
      @search = Sunspot.search(Place) do
        fulltext                   params[:name]           if params[:name].present?
        with(:subject_slugs).any_of [params[:subject_id]]  if params[:subject_id]

        with(:location).in_radius(city.latitude, city.longitude, params[:radius] || 10, :bbox => true)

        with :active,  true

        paginate :page => (params[:page] || 1), :per_page => 15
      end
      @places = @search.results

      init_geoloc

      respond_to do |format|
        format.html
      end
    end
  end

  private
  def init_geoloc
    # To remove
    @places.each do |place|
      place.geolocalize unless place.is_geolocalized?
    end
    place_index = 0
    @json_place_addresses = @places.to_gmaps4rails do |place, marker|
      place_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='#'><span>#{place_index}</span></a></div>"
                     })
      marker.title   place.name
      marker.json({ id: place.id })
    end
  end
  def prepare_search
    if params[:city].blank?
      if request.location.city.blank?
        city_term = 'paris'
      else
        city_term = request.location.city
      end
      city_slug = request.location.city
    else
      city_term  = "#{params[:city]}%"
      city_slug  = params[:city]
    end
    @city      = City.where{(slug == city_slug ) | (name =~ city_term)}.order('name ASC').first # Prevents from bad slugs
  end
end
