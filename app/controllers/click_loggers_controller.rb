class ClickLoggersController < InheritedResources::Base
  protect_from_forgery :except => :create

  actions :create

  respond_to :json
end
