# encoding: utf-8
class HomeController < ApplicationController

  def index
    # For search
    @audiences        = Audience.all
    @levels           = Level.all
    @comments         = Comment.accepted.order('created_at DESC').limit(4)
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
