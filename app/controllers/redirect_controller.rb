class RedirectController < ApplicationController
  include SubjectHelper

  # GET http://coursavenue.com
  # Catching root url without subdomain. Mainly for dev.
  def www_root
    redirect_to root_url(subdomain: 'www'), status: 301
  end

  # GET pro.coursavenue.com/paris, etc.
  # Redirects all links like pro.coursavenue.com/paris to www. subdomain
  def structures_index
    params[:city_id] ||= 'paris'
    # The slug of those two subjects were like: ecriture-theatrale--3
    if ['restauration-d-art', 'ecriture-theatrale'].include?(params[:subject_id]) and params[:city_id] == '3'
      params[:city_id] = params[:old_city_slug]
    end
    if params[:subject_id].present?
      redirect_to search_page_url(params[:root_subject_id], params[:subject_id], params[:city_id], subdomain: 'www'), status: 301
    elsif params[:root_subject_id].present?
      redirect_to root_search_page_url(params[:root_subject_id], params[:city_id], subdomain: 'www'), status: 301
    else
      redirect_to root_search_page_without_subject_url(params[:city_id], subdomain: 'www'), status: 301
    end
  end

  def vertical_page
    @subject = Subject.fetch_by_id_or_slug params[:id]
    if @subject
      redirect_to root_search_page_url(@subject.root, 'paris', subdomain: 'www'), status: 301
    else
      redirect_to vertical_pages_url(subdomain: 'www'), status: 301
    end
  end

  def vertical_page_city
    @subject = Subject.fetch_by_id_or_slug params[:subject_id]
    @city    = City.find params[:id]
    redirect_to root_search_page_url(@subject.root, @city, subdomain: 'www'), status: 301
  end

  def vertical_page_subject_city
    @subject = Subject.fetch_by_id_or_slug params[:subject_id]
    @city    = City.find params[:id]
    redirect_to root_search_page_url(@subject.root, @city, subdomain: 'www'), status: 301
  end

  def why_coursavenue
    redirect_to pages_what_is_it_url, status: 301
  end

  def blog
    redirect_to 'https://www.coursavenue.com/blog', status: 301
  end

  def structures_new
    redirect_to inscription_pro_structures_url(params_for_search.merge(subdomain: 'www')), status: 301
  end

  def disciplines
    redirect_to subject_courses_url(params[:id], subdomain: 'www'), status: 301
  end

  def place_show
    redirect_to structure_url(params[:id], subdomain: 'www'), status: 301
  end

  def place_index
    redirect_to structures_url(params_for_search.merge(subdomain: 'www')), status: 301
  end

  def subject_place_index
    redirect_to subject_structures_url(params[:subject_id], params_for_search.merge(subdomain: 'www')), status: 301
  end

  def lieux
    redirect_to structures_url(params_for_search.merge(subdomain: 'www')), status: 301
  end

  def lieux_show
    redirect_to structure_url(params[:id], subdomain: 'www'), status: 301
  end

  def city
    redirect_to courses_url(subdomain: 'www'), status: 301
  end

  def city_subject
    redirect_to subject_courses_url(params[:subject_id], subdomain: 'www'), status: 301
  end

  # GET 'cours/:id--:city_id'
  def vertical_pages__show_with_city
    redirect_to root_vertical_page_with_city_url(params.merge(subdomain: 'www'))
  end
  # GET 'cours/:id'
  def vertical_pages__show_root
    redirect_to root_vertical_page_url(params.merge(subdomain: 'www'))
  end
  # GET 'cours/:root_subject_id/:id'
  def vertical_pages__show
    redirect_to vertical_page_url(params.merge(subdomain: 'www'))
  end
  # GET 'cours/:root_subject_id/:id/:city_id'
  def vertical_pages__show_with_city
    redirect_to vertical_page_with_city_url(params.merge(subdomain: 'www'))
  end

  # GET 'guide-des-disciplines'
  def vertical_pages__index
    redirect_to vertical_pages_url(params.merge(subdomain: 'www'))
  end

  private

  def params_for_search
    params.delete(:action)
    params.delete(:controller)
    params
  end
end
