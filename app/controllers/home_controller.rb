# encoding: utf-8
class HomeController < ApplicationController

  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @comments         = Comment.accepted.order('created_at DESC').limit(5)
    @homepage_images  = [['home-page/dance.jpg', 'Cours de danse']]
                         # ,['home-page/painter.jpg', 'Cours de peinture']]
    @structures = StructureSearch.search({lat: 48.8540,
                                          lng: 2.3417,
                                          radius: 5,
                                          sort: 'rating_desc',
                                          has_logo: true,
                                          per_page: 130,
                                          bbox: true
                                        }).results

    @json_locations_addresses = Gmaps4rails.build_markers(@structures) do |structure, marker|
      marker.lat structure.latitude
      marker.lng structure.longitude
    end

  end

  def contact
    @errors = []
    @errors << :name    if params[:name].blank?
    @errors << :email   if params[:email].blank?
    @errors << :content if params[:content].blank?
    if @errors.any?
      render 'pages/contact', alert: 'Tous les champs doivent être remplis'
    else
      UserMailer.delay.contact(params[:name], params[:email], params[:content])
      redirect_to pages_contact_path, notice: "Votre message à bien été transmis à l'équipe CoursAvenue !"
    end
  end
end
