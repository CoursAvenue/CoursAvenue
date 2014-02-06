class Subjects::Cities::MediasController < ApplicationController
  def videos
    @subject          = Subject.friendly.find params[:subject_id]
    @city             = City.friendly.find params[:city_id]
    @structure_search = StructureSearch.search({ lat: @city.latitude,
                                                 lng: @city.longitude,
                                                 radius: 4,
                                                 sort: 'rating_desc',
                                                 has_logo: true,
                                                 per_page: 150,
                                                 subject_id: @subject.slug })

    @structures = @structure_search.results
    @videos     = @structures.map { |structure| structure.medias.videos }.flatten
    @videos     = Kaminari.paginate_array(@videos).page(params[:page]).per(8)
  end
end
