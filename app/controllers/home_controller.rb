# encoding: utf-8
class HomeController < ApplicationController

  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @promoted_courses = Course.where{is_promoted == true}.shuffle[0...3]
    @comments         = Comment.accepted.order('created_at DESC').limit(5)
    @homepage_images  = [['home-page/dance.jpg', 'Cours de danse']]
                         # ,['home-page/painter.jpg', 'Cours de peinture']]
    @structures = StructureSearch.search({lat: 48.8540,
                                          lng: 2.3417,
                                          radius: 5,
                                          sort: 'rating_desc',
                                          has_logo: true,
                                          per_page: 1000,
                                          bbox: false
                                        }).results

    @json_locations_addresses = @structures.to_gmaps4rails do |structure, marker|
      marker.json({ id: structure.slug })
    end

    # fresh_when @comments.first, etag: [@comments.first, ENV["ETAG_VERSION_ID"]], public: true
    # expires_in 1.minute, public: true
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
