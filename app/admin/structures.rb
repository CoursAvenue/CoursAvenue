ActiveAdmin.register Structure do
  index do
    column :city
    column :structure_type
    column :name
    default_actions
  end
end
