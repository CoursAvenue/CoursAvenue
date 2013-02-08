ActiveAdmin.register Subject do
  index do
    column "Image" do |subject|
      if subject.image.present?
        "<i class='icon-ok'></i>".html_safe
      end
    end
    column "Maman" do |subject|
      unless subject.is_root?
        subject.parent.name
      end
    end
    column "Nom" do |subject|
      link_to subject.name, edit_admin_subject_path(subject)
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
