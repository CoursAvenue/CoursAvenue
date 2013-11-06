class RenameArtsSubjects < ActiveRecord::Migration
  def change
    art = Subject.find 'dessin-peinture-arts-plastiques'
    art.update_column :name, 'Dessin, Peinture & Arts'
  end
end
