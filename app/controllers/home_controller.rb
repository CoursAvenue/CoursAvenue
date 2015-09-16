# encoding: utf-8
class HomeController < ApplicationController

  layout 'pages'

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

  # Because fuck you Microsoft.
  def browserconfig
    respond_to do |format|
      format.xml { render xml: {} }
      format.html { redirect_to root_path }
    end
  end

  def humans
    respond_to do |format|
      format.text { render text: 'On recrute! RDV sur www.coursavenue.com/jobs.' }
    end
  end

  private

  def layout_locals
    locals = { }
    locals[:hide_header] = true if action_name == 'resolutions' or action_name == 'resolutions_results'
    locals
  end
end
