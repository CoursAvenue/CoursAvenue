ActiveAdmin.register Place do
  index do
    column :city
    column :name
    default_actions
  end
end
