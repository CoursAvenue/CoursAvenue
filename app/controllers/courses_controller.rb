# encoding: utf-8
class CoursesController < ApplicationController
  layout 'home'

  before_action :redirection
  def redirection
    if params[:root_subject_id] == 'other'
      redirect_to root_search_page_without_subject_url(params[:city_id], subdomain: 'www'), status: 301
      return
    end
  end

  def index
    @city = City.find(params[:city_id]) rescue City.find('paris')
    if params[:subject_id].present? or params[:root_subject_id].present?
      @subject      = Subject.find(params[:subject_id] || params[:root_subject_id])
      @root_subject = @subject.root
    end
    @favorite_cards = current_user.present? ? current_user.favorites.cards.pluck(:indexable_card_id) : []
  end
end
