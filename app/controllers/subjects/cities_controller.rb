class Subjects::CitiesController < ApplicationController
  def show
    # The slug of those two subjects were like: ecriture-theatrale--3
    if params[:subject_id].include?('restauration-d-art') or params[:subject_id].include?('ecriture-theatrale')
      params[:subject_id] = params[:subject_id].gsub(/--.*/, '')
    end
    @subject = Subject.fetch_by_id_or_slug params[:subject_id]
    if @subject.vertical_pages.any?
      redirect_to vertical_page_path(@subject.root, @subject.vertical_pages.first), status: 301
    elsif @subject.parent and @subject.parent.vertical_pages.any?
      redirect_to vertical_page_path(@subject.root, @subject.parent.vertical_pages.first), status: 301
    elsif @subject.root.vertical_pages.any?
      redirect_to vertical_page_path(@subject.root, @subject.root.vertical_pages.first), status: 301
    else
      redirect_to root_path, status: 410
    end
  end
end
