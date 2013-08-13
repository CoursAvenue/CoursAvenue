class RedirectController < ApplicationController

  def structure_course
    course    = Course.find params[:id]
    redirect_to structure_course_path(course.structure, course), status: 301
  end

  def why_coursavenue
    redirect_to pages_why_path, status: 301
  end

  def blog
    redirect_to 'http://www.coursavenue.com/blog', status: 301
  end

  def structures_new
    redirect_to inscription_pro_structures_path(params_for_search), status: 301
  end

  def disciplines
    redirect_to subject_courses_path(params[:id]), status: 301
  end

  def place_show
    redirect_to place_path(params[:id]), status: 301
  end

  def place_index
    redirect_to places_path(params_for_search), status: 301
  end

  def subject_place_index
    redirect_to subject_places_path(params[:subject_id], params_for_search), status: 301
  end

  def lieux
    redirect_to places_path(params_for_search), status: 301
  end

  def lieux_show
    redirect_to place_path(params[:id]), status: 301
  end

  def city
    redirect_to courses_path, status: 301
  end

  def city_subject
    redirect_to subject_courses_path(params[:subject_id]), status: 301
  end

  private
  def params_for_search
    params.delete(:action)
    params.delete(:controller)
    params
  end
end
