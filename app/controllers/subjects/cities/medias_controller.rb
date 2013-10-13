class Subjects::Cities::MediasController < ApplicationController

  def videos
    @subject          = Subject.find params[:subject_id]
    @city             = City.find params[:city_id]
    @structure_search = StructureSearch.search({lat: @city.latitude,
                                          lng: @city.longitude,
                                          radius: 4,
                                          sort: 'rating_desc',
                                          has_logo: true,
                                          per_page: 150,
                                          subject_id: @subject.slug
                                        })

    @structures = @structure_search.results
    @videos     = @structures.collect{|structure| structure.medias.videos }.flatten
  end
end
