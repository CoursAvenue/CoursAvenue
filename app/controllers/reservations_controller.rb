# encoding: utf-8
class ReservationsController < ApplicationController

  before_filter :retrieve_info

  def new
    @reservation = Reservation.new
  end

  def show
    @reservation = Reservation.find params[:id]
  end

  def create
    @reservation = @course.reservations.build params[:reservation]
    respond_to do |format|
      if @reservation.save
        format.html { redirect_to course_reservation_path(@course, @reservation), notice: 'Votre réservation à bien été pris en compte. Un mail vous a été envoyé.' }
        UserMailer.alert_structure_for_reservation(@reservation).deliver!
        UserMailer.alert_user_for_reservation(@reservation).deliver!
      else
        format.html { render action: :new }
      end
    end
  end

  private
  def retrieve_info
    @course       = Course.find params[:course_id]
    @structure    = @course.structure
    @place        = @course.place
    @plannings    = @course.plannings
    @prices       = @course.prices
    @book_tickets = @course.book_tickets
  end
end
