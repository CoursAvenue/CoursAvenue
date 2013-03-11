# encoding: utf-8
class Pro::RoomsController < InheritedResources::Base#Pro::ProController
  layout 'admin'

  nested_belongs_to :structure, :place
  load_and_authorize_resource :structure

  def create
    @rooms = @place.rooms
    create! do |success, failure|
      success.html { redirect_to structure_place_rooms_path(@structure, @place) }
      failure.html { render template: 'pro/rooms/index'}
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to structure_place_rooms_path(@structure, @place) }
      failure.html { render template: 'pro/rooms/index'}
    end
  end
end
