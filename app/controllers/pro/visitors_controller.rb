# encoding: utf-8
class Pro::VisitorsController < Pro::ProController

  def index
    @visitors = Visitor.all

    respond_to do |format|
      format.html
    end
  end

  def show
    @visitor = Visitor.where(fingerprint: params[:id]).first
    @comments = @visitor.comments

    respond_to do |format|
      format.html
    end
  end
end
