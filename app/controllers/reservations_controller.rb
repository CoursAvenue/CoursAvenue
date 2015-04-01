# encoding: utf-8
class ReservationsController < ApplicationController
  def new
    @course = Course.where(id: params[:course_id]).first
    if @course
      redirect_to structure_course_path @course.structure, @course, status: 301
    else
      redirect_to root_path status: 301
    end
  end

  def create
    _reservable_type = params[:reservation][:reservable_type]
    _reservable_id   = params[:reservation][:reservable_id]
    if current_user and current_user.reservations.where( Reservation.arel_table[:reservable_type].eq(_reservable_type).and(
                                                         Reservation.arel_table[:reservable_id].eq(_reservable_id)) ).empty?
      @reservable       = find_reservable
      @reservation      = @reservable.reservations.build params[:reservation]
      @reservation.user = current_user
    end
    respond_to do |format|
      format.js { render nothing: true }
      if @reservation && @reservation.save
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
