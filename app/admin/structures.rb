ActiveAdmin.register Structure do
  form do |f|
    f.inputs do
      f.input :places, input_html: {style: 'height: 200px;'} # add roles input here
      f.input :structure_type
      f.input :name
      f.input :info
      f.input :registration_info
      f.input :gives_professional_courses
      f.input :website
      f.input :phone_number
      f.input :mobile_phone_number
      f.input :email_address
    end
    f.buttons
  end

  index do
    column :structure_type
    column :name
    default_actions
  end

  # show do
  #   column :structure_type
  #   column :name
  #   default_actions
  # end
end
