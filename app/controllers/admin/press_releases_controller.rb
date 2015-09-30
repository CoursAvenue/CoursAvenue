# encoding: utf-8
class Admin::PressReleasesController < Admin::AdminController
  def index
    @press_releases = ::PressRelease.all
  end

  def new
    @press_release = ::PressRelease.new
  end

  def edit
    @press_release = ::PressRelease.find(params[:id])
  end

  def show
    @press_release = ::PressRelease.find(params[:id])
  end

  def create
    @press_release = ::PressRelease.new params[:press_release]
    respond_to do |format|
      if @press_release.save
        format.html { redirect_to admin_press_releases_path }
      else
        format.html { render action: :new }
      end
    end
  end

  def update
    @press_release = ::PressRelease.find params[:id]
    respond_to do |format|
      if @press_release.update_attributes params[:press_release]
        format.html { redirect_to admin_press_releases_path }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @press_release = ::PressRelease.find params[:id]
    @press_release.destroy
    respond_to do |format|
      format.html { redirect_to admin_press_releases_path, notice: "Supprimé !" }
    end
  end
end
