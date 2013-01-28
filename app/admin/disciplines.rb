ActiveAdmin.register Discipline do
  index do
    column "Image" do |discipline|
      if discipline.image.present?
        "<i class='icon-ok'></i>".html_safe
      end
    end
    column "Nom" do |discipline|
      link_to discipline.name, edit_admin_discipline_path(discipline)
    end
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
   f.inputs "Details" do
    f.input :name
    f.input :image, :as => :file
  end
  f.buttons
 end
end
