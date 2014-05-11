# encoding: utf-8
class KeywordsController < ApplicationController
  def index
    @keywords = Keyword.search { fulltext params[:name] }.results
    respond_to do |format|
      format.json { render json: @keywords.to_json }
    end
  end
end
