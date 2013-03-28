# encoding: utf-8
class PagesController < ApplicationController
  def rent_places
    @renting_room = RentingRoom.new
  end
end
