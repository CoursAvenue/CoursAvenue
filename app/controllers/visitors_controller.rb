# encoding: utf-8
class VisitorsController < ApplicationController

  respond_to :json

  def index
    @visitors = Visitor.all

    respond_to do |format|
      format.html
    end
  end

  def show
    @visitor = Visitor.where(fingerprint: params[:fingerprint]).first
    @comments = @visitor.comments

    respond_to do |format|
      format.html
    end
  end

  def create
    @visitor = Visitor.where(fingerprint: params[:fingerprint]).first_or_create
    params[:visitor].delete(:fingerprint)

    params[:comments].each do |data|
      comment = @visitor.comments.build

      comment.fields     = data
      comment.ip_address = request.remote_ip
    end

    @visitor.update_attributes!(params[:visitor])
    @visitor.save!

    respond_with @visitor
  end

  def update
  end

end
