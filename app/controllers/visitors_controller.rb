# encoding: utf-8
class VisitorsController < ApplicationController

  respond_to :json

  def create
    @visitor = Visitor.where(fingerprint: params[:fingerprint].to_s).first_or_create
    params[:visitor].delete(:fingerprint)

    build_visitors unless params[:comments].nil?

    @visitor.update_attributes(params[:visitor])
    @visitor.save!

    respond_with @visitor
  end

  def update
  end

  private

  # for each set of attributes for comments, we build
  # on comment and include the field data and ip address
  # TODO later we will do this in update_attributes by
  #   using accepts_nested_attributes_for
  def build_visitors
    params[:comments].each do |data|
      comment = @visitor.comments.build

      comment.fields     = data
      comment.ip_address = request.remote_ip
    end
  end

end
