# encoding: utf-8
class KeywordsController < ApplicationController
  def index
    _name = "#{params[:name]}%"
    @keywords = Keyword.where{name =~ _name}
    respond_to do |format|
      format.json { render json: @keywords.to_json }
    end
  end
end
