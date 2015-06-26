# encoding: utf-8
class HomeController < ApplicationController

  layout :get_layout

  def resolutions
  end

  def resolutions_results
  end

  def redirect_to_account
    if current_user
      redirect_to dashboard_user_path(current_user)
    else
      redirect_to root_path(anchor: 'connexion')
    end
  end

  def index
    @google_search_box_metadata = {
      "@context" => "http://schema.org",
      "@type" => "WebSite",
      "url" => root_url,
      "potentialAction" => {
        "@type" => "SearchAction",
        "target" => "#{root_url}paris?name={search_term_string}",
        "query-input" => "required name=search_term_string"
      }
    }
  end

  private

  def get_layout
    if action_name == 'pass_decouverte' or
       action_name == 'resolutions' or
       action_name == 'resolutions_results'
      'empty'
    elsif action_name == 'index'
      'home'
    else
      'pages'
    end
  end

  def layout_locals
    locals = { }
    locals[:hide_top_menu_search] = true if action_name == 'index'
    locals[:hide_header] = true if action_name == 'resolutions' or action_name == 'resolutions_results'
    locals
  end
end
