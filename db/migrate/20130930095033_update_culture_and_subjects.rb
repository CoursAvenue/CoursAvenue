# encoding: utf-8
class UpdateCultureAndSubjects < ActiveRecord::Migration
  def up
    culture_sciences_nature = rename_subject 'culture-sciences', 'Culture, Sciences & Nature'
    culture_science = rename_subject 'sciences-ciel-terre', 'Culture & Sciences'
    rename_subject 'decouverte-des-sciences', 'Sciences, ciel & terre'
    delete_subjects ['geologie', 'mineralogie-gemmologie', 'astronomie', 'meteorologie', 'orpaillage', 'volcans']
    update_parent 'robotique', culture_science
    jeux = update_parent 'jeux', culture_science
    jeux.children.map(&:destroy)
    delete_subject 'ciel-terre'
    delete_subject 'sciences'
    culture_civilisation = update_parent 'culture-civilisation', culture_science
    culture_civilisation.children.map(&:destroy)
    update_parent 'lecture', 'theatre'

    update_parent 'nature-animaux', 'culture-sciences-nature'
    chasse_peche = update_parent 'chasse-peche', 'nature-animaux'
    chasse_peche.children.map(&:destroy)
    chiens = update_parent 'chiens-animaux-domestiques', 'nature-animaux'
    chiens.children.map(&:destroy)
    animaux = update_parent 'decouverte-des-animaux', 'nature-animaux'
    animaux.children.map(&:destroy)
    nature = update_parent 'decouverte-nature', 'nature-animaux'
    nature.children.map(&:destroy)
    decouverte_nature = rename_subject 'decouverte-nature', 'Découverte de la nature'
    decouverte_nature.children.map(&:destroy)
    ecologie_developpement = update_parent 'ecologie-developpement-durable', 'nature-animaux'
    ecologie_developpement.children.map(&:destroy)
    flore_botanique = update_parent 'flore-botanique', 'nature-animaux'
    flore_botanique.children.map(&:destroy)
    jardinage = update_parent 'jardinage', 'nature-animaux'
    jardinage.children.map(&:destroy)
    delete_subject 'ferme-animaux-de-ferme'
    delete_subject 'chasse'
    delete_subject 'peche'
    delete_subject 'milieux-naturels'

    # Line 309
    deco_construction = rename_subject 'decoration', 'Décoration & Construction'
    delete_subject 'ecoconstruction'
    deco_construction.children.create name: 'Techniques de construction'
    update_parent 'feng-shui-deco', deco_construction

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
