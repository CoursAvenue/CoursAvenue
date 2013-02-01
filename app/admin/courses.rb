ActiveAdmin.register Course do

  form :html => { :enctype => "multipart/form-data" } do |f|
   f.inputs "image" do
    f.input :is_promoted
    f.input :homepage_image, :as => :file
    end
    f.buttons
  end
end
