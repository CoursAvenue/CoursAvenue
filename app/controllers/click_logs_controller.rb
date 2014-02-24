class ClickLogsController < InheritedResources::Base
  protect_from_forgery except: :create

  actions :create

  respond_to :js

  def create
    create! do |format|
      format.js { render nothing: true }
    end
  end
end
