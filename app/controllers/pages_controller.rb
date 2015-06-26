# encoding: utf-8
class PagesController < ApplicationController

  layout 'pages'

  def faq_partners
    redirect_to pro_pages_questions_url(subdomain: 'pro'), status: 301
  end

  def send_message
    @errors = []
    @errors << :name    if params[:name].blank?
    @errors << :email   if params[:email].blank?
    @errors << :content if params[:content].blank?
    respond_to do |format|
      if @errors.any?
        format.html { render 'pages/contact', alert: 'Tous les champs doivent être remplis' }
      else
        UserMailer.delay.contact(params[:name], params[:email], params[:content])
        format.html { redirect_to pages_contact_path, notice: "Votre message a bien été transmis à l'équipe CoursAvenue !" }
      end
    end
  end

  def press
    @press_releases = PressRelease.published
  end

  def faq_users
    @sections = ::Faq::Section.user
  end
end
