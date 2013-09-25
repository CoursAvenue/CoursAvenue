# encoding: utf-8
class EmailsController < InheritedResources::Base
  actions :create

  def create
    create! do |format|
      format.html { redirect_to pro_pages_price_path, notice: 'Merci pour votre email ! Nous vous recontacterons dès le lancement.' }
    end
  end
end
