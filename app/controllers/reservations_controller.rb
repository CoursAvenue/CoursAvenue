# encoding: utf-8
class ReservationsController < ApplicationController

  before_filter :retrieve_info

  def new
    @reservation = Reservation.new
  end

  def create
    @reservation = @course.reservations.build params[:reservation]
    # @reservation = Reservation.new params[:reservation]
    respond_to do |format|
      if @reservation.save
        format.html { redirect_to course_path(@course), notice: 'Votre réservation à bien été pris en compte. Un mail vous a été envoyé.' }
        UserMailer.make_reservation(@reservation).deliver!
      else
        format.html { render action: :new }
      end
    end
  end

  private
  def retrieve_info
    @course       = Course.find params[:course_id]
    @plannings    = @course.plannings
    @prices       = @course.prices
    @book_tickets = @course.book_tickets
  end
end
