# encoding: utf-8
class Pro::RoomsController < InheritedResources::Base
  layout 'admin'

  nested_belongs_to :structure, :place
  load_and_authorize_resource :structure, find_by: :slug

  def create
    @rooms = @place.rooms
    create! do |success, failure|
      success.html { redirect_to pro_structure_place_rooms_path(@structure, @place) }
      failure.html { render template: 'pro/rooms/index'}
    end
  end

  def edit
    @room = Room.find(params[:id])
    @rooms = @place.rooms.reject{ |room| room == @room }
    render template: 'pro/rooms/index'
  end

  def update
    @rooms = @place.rooms
    update! do |success, failure|
      success.html { redirect_to pro_structure_place_rooms_path(@structure, @place) }
      failure.html { render template: 'pro/rooms/index'}
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to pro_structure_place_rooms_path(@structure, @place) }
      failure.html { render template: 'pro/rooms/index'}
    end
  end
end
