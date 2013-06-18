# encoding: utf-8
class ReservationsController < ApplicationController
  include ReservationHelper

  def new
    @course = Course.find params[:course_id]
    redirect_to course_path @course, status: 301
  end

  def create
    @reservable  = find_reservable
    @reservation = @reservable.reservations.build params[:reservation]
    @reservation.user = current_user
    respond_to do |format|
      if @reservation.save
        # format.html { redirect_to reservable_path(@reservation), notice: 'Votre réservation à bien été pris en compte. Un mail vous a été envoyé.' }
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
