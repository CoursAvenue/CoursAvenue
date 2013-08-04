# encoding: utf-8
class ReservationsController < ApplicationController
  include ReservationHelper

  def new
    @course = Course.find params[:course_id]
    redirect_to place_course_path @course.place, @course, status: 301
  end

  def create
    _reservable_type = params[:reservation][:reservable_type]
    _reservable_id   = params[:reservation][:reservable_id]
    _use_id          = current_user.id
    if current_user.reservations.where{(reservable_type == _reservable_type) & (reservable_id == _reservable_id)}.empty?
      @no
      @reservable       = find_reservable
      @reservation      = @reservable.reservations.build params[:reservation]
      @reservation.user = current_user
    end
    respond_to do |format|
      if @reservation and @reservation.save
        UserMailer.delay.alert_structure_for_reservation(@reservation)
        UserMailer.delay.alert_user_for_reservation(@reservation)
      end
    end
  end

  private

  private
  def find_reservable
    type = params[:reservation][:reservable_type]
    type.classify.constantize.find(params[:reservation][:reservable_id])
  end
end
