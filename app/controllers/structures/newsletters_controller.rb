class Structures::NewslettersController < ApplicationController

  before_action :set_structure

  def show
    @newsletter = @structure.newsletters.includes(:blocs).find params[:id]

    mail = NewsletterMailer.send_newsletter(@newsletter, nil)
    @body = MailerPreviewer.preview(mail)

    render layout: false
  end

  private

  def set_structure
    @structure = Structure.friendly.find(params[:structure_id])
  end
end
