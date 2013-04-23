# encoding: utf-8
class ReservationsController < ApplicationController

  before_filter :retrieve_info

  def new
    redirect_to course_path(@course), status: 301
  end

  private
  def retrieve_info
    @course       = Course.find params[:course_id]
  end
end
