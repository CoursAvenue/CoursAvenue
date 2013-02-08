ActiveAdmin.register City do
  index do
    column "Image" do |city|
      if city.no_result_image.present?
        "<i class='icon-ok'></i>".html_safe
      end
    end
    column "Nom" do |city|
      link_to city.name, edit_admin_city_path(city)
    end
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Details" do
      f.input :name
      f.input :no_result_image, :as => :file
    end
    f.buttons
  end
end
