# encoding: utf-8
class VisitorsController < ApplicationController

  respond_to :json

  def index
    @visitors = Visitor.all

    respond_with @visitors
  end

  def create
    @visitor = Visitor.where(fingerprint: params[:fingerprint]).first_or_create
    params[:visitor].delete(:fingerprint)

    @visitor.update_attributes!(params[:visitor])

    respond_with @visitor
  end

  def update
  end

end
