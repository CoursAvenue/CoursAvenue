ActiveAdmin.register Course do
  index do
    column "Mise en avant" do |course|
      if course.is_promoted?
        "<i class='icon-ok'></i>".html_safe
      end
    end
    column "CB" do |course|
      if course.has_online_payment?
        "<i class='icon-ok'></i>".html_safe
      end
    end
    column "Nom" do |subject|
      link_to subject.name, edit_admin_course_path(subject)
    end
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
   f.inputs "image" do
    f.input :name, label: "Nom"
    f.input :slug, label: "slug"
    f.input :is_promoted, label: "Sur la page d'accueil"
    f.input :has_online_payment, label: 'Paiement en ligne'
    f.input :homepage_image, as: :file
    f.input :subjects
    end
    f.buttons
  end
end
