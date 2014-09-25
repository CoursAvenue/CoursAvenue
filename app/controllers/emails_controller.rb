# encoding: utf-8
class EmailsController < InheritedResources::Base
  actions :create

  def create
    create! do |format|
      format.html { redirect_to pass_decouverte_path(inscription: 'ok', utm_campaign: params[:utm_campaign]), notice: 'Merci pour votre confiance ! Nous vous recontacterons dès le lancement.' }
    end
  end
end
