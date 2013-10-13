# encoding: utf-8
class UpdateDecoModePhotoSubjects < ActiveRecord::Migration
  def up
    mode_beaute         = Subject.friendly.find 'mode-beaute'
    deco_mode_bricolage = Subject.friendly.find 'deco-mode-bricolage'
    mode_beaute.children.each do |child|
      child.parent = deco_mode_bricolage
      child.save
    end
    couture_creation_text = rename_subject 'creation-de-vetements', 'Couture & création textile'
    rename_subject 'creation-d-accessoires-sacs-chapeaux', "Création de vêtements & d'accessoires"
    beaute_savoir_plaire = rename_subject 'beaute', 'Beauté & Savoir plaire'
    delete_subject 'forme-ligne'

    delete_subjects ['creation-d-accessoires', 'couture-et-creation-de-vetements']
    update_parent 'relooking-conseil-en-image', beaute_savoir_plaire
    delete_subject 'relooking'
    update_parent 'effeuillage-cabaret-strip-tease', beaute_savoir_plaire
    delete_subject 'effeuillage'
    update_parent 'seduction', beaute_savoir_plaire
    update_parent 'coaching-amoureux', beaute_savoir_plaire

    biz_informatique = Subject.create name: 'Business & Informatique'
    informatique = update_parent 'informatique', biz_informatique
    update_parent 'decouverte-de-l-informatique', 'informatique'
    delete_subject 'initiation-a-l-informatique'
    delete_subject 'infographie-pao-infographie'
    update_parent 'creation-de-site-internet', informatique
    update_parent 'initiation-navigation-internet', informatique
    delete_subject 'internet'
    business = update_parent 'business', biz_informatique
    update_parent 'begaiement', business
    rename_subject 'begaiement', 'Diction & bégaiement'
    update_parent 'travail-de-la-voix', business
    update_parent 'communication-relation-presse', business
    update_parent 'entrepeneuriat-creation-d-entreprise', business
    update_parent 'gestion-d-entreprise', business
    update_parent 'finance-comptabilite', business
    update_parent 'techniques-de-vente-marketing', business
    update_parent 'comportement-gestion-des-conflits', business
    rename_subject 'communication-relation-presse', 'Communication & relations presse'
    delete_subjects ['communication', 'entrepeneuriat', 'gestion', 'marketing', 'developpement']
    delete_subject 'humanitaire-solidaire'
    delete_subject 'insolite'
    delete_subject 'savoir-plaire'
    update_parent 'creation-de-vetements-d-accessoires', couture_creation_text
    delete_subject 'creation-de-vetements'
    delete_subject 'creation-de-vetements--2'

    rename_subject 'infographie-pao-pao-publication-assistee-par-ordinateur', 'Infographie & PAO (Publication Assistée par Ordinateur)'

    mother_langue = Subject.friendly.find 'langues-soutien-scolaire'
    mother_langue.children.map(&:destroy)
    langue   = mother_langue.children.create name: 'Langues'
    langue.children.create name: "Apprentissage d'une langue"
    soutiens = mother_langue.children.create name: 'Soutien scolaire'
    soutiens.children.create name: "Coaching scolaire"
    soutiens.children.create name: "Séjours de soutien scolaire"
    soutiens.children.create name: "Soutien scolaire à domicile"
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
