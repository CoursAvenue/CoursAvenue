class StructuresController < ApplicationController

  before_filter :prepare_search

  def show
    @structure = Structure.find params[:id]
    @courses   = @structure.courses.joins{plannings}.where{plannings.end_date > Date.today}.group(:id)
    @comment   = @structure.comments.build
    @comments  = @structure.comments.order('created_at DESC').reject(&:new_record?)
    @city      = @structure.city

    @json_structure_address = @structure.to_gmaps4rails do |structure, marker|
      marker.title   structure.name
      marker.json({ id: structure.id })
    end

  end
  def index
    if @city.nil?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "La ville que vous recherchez n'existe pas" }
      end
    else
      cookies[:structure_search_path] = request.fullpath
      city       = @city

      @search = Sunspot.search(Structure) do
        fulltext                   params[:name]         if params[:name].present?
        with(:subject_ids).any_of [params[:subject_id]]  if params[:subject_id]

        with(:location).in_radius(city.latitude, city.longitude, params[:radius] || 10, :bbox => true)

        with :active,  true

        paginate :page => (params[:page] || 1), :per_page => 15
      end
      @structures = @search.results

      init_geoloc

      respond_to do |format|
        format.html
      end
    end
  end

  private
  def init_geoloc

    # To remove
    @structures.each do |structure|
      structure.geolocalize unless structure.is_geolocalized?
    end
    structure_index = 0
    @json_strcuture_addresses = @structures.to_gmaps4rails do |structure, marker|
      structure_index += 1
      marker.picture({
                      :marker_anchor => [10, true],
                      :rich_marker   => "<div class='map-marker-image' style='font-size: 13px; top: -2em;'><a href='#'><span>#{structure_index}</span></a></div>"
                     })
      marker.title   structure.name
      marker.json({ id: structure.id })
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
