class ReservationLoggersController < InheritedResources::Base
  protect_from_forgery except: :create

  actions :create
  belongs_to :course

  respond_to :json
end
