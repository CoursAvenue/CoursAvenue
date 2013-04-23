# encoding: utf-8
class ReservationsController < ApplicationController

  before_filter :retrieve_info

  def new
    redirect_to course_path(@course), status: 301
  end

  def create
    @reservation       = @course.reservations.build params[:reservation]
    @reservation.price = @course.prices.where{nb_courses == 1}.first
    respond_to do |format|
      if @reservation.save
        format.html { redirect_to course_path(@course), notice: 'Votre réservation à bien été pris en compte. Un mail vous a été envoyé.' }
        UserMailer.alert_structure_for_reservation(@reservation).deliver!
        UserMailer.alert_user_for_reservation(@reservation).deliver!
      else
        format.html { redirect_to course_path(@course), alert: "Veuillez remplir tous les champs pour votre réservation." }
      end
    end
  end

  private

  def retrieve_info
    @course       = Course.find params[:course_id]
  end
end
