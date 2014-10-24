# encoding: utf-8
class PressReleasesController < ApplicationController

  layout 'pages'

  def show
    @press_release = ::PressRelease.find params[:id]
  end

end
