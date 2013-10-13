# encoding: utf-8
class UpdateCuisineSubjects < ActiveRecord::Migration
  def up
    cuisine_vins       = Subject.friendly.find 'cuisine-vins'
    cuisine_par_region = cuisine_vins.children.create(name: 'Cuisine par pays & régions')
    subj = update_parent 'cuisine-d-amerique-et-des-iles', cuisine_par_region
    subj.children.map(&:destroy)
    subj = update_parent 'cuisine-europeenne', cuisine_par_region
    subj.children.map(&:destroy)
    subj = update_parent 'cuisine-francaise', cuisine_par_region
    subj.children.map(&:destroy)
    subj = update_parent 'cuisine-orientale', cuisine_par_region
    subj.children.map(&:destroy)
    subj = update_parent 'cuisine-africaine', cuisine_par_region
    subj.children.map(&:destroy)
    subj = update_parent 'cuisine-asiatique', cuisine_par_region
    subj.children.map(&:destroy)

    delete_subject 'degustation-de-cognacs'

    degustation = Subject.friendly.find 'degustations-produits'
    degustation.children.create name: 'Dégustations diverses'
    delete_subjects ['fabrication-de-beurre', 'decouvertes-gastronomiques', 'degustation-d-algues', 'degustation-d-huiles-vinaigres', 'degustation-d-eaux', 'degustation-de-cafe', 'degustation-de-champignons', 'degustation-de-charcuteries-fines', 'degustation-de-chataignes-marrons', 'degustation-de-fleurs-sauvages']
    delete_subjects ['crepes-galettes-gaufres', 'nougatine-caramel-sucres-d-art', 'confitures', 'crepes', 'glaces-cremes']
    delete_subjects ['bonbons-confiserie', 'cakes-pains-d-epices', 'nougatine', 'pain', 'patisseries-orientales']
    rename_subject 'patisseries-variees', 'Pâtisseries autres'

    vin = Subject.friendly.find 'vin-alcools'
    vins = Subject.friendly.find 'vins-alcools'
    vin.children.each do |child|
      child.parent = vins
      child.save
    end
    vin.destroy
  end

  def down
  end

  def rename_subject slug, new_name
    subject      = Subject.friendly.find slug
    subject.name = new_name
    subject.save
    return subject
  end

  def delete_subject slug
    subject      = Subject.friendly.find slug
    subject.destroy
  end

  def delete_subjects slugs
    slugs.each do |slug|
      delete_subject(slug)
    end
  end

  def update_parent slug, parent_slug
    child  = Subject.friendly.find(slug)
    if parent_slug.is_a? String
      parent = Subject.friendly.find(parent_slug)
    else
      parent = parent_slug
    end
    child.parent = parent
    child.save
    return child
  end
end
