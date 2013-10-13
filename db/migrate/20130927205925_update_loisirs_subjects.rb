# encoding: utf-8
class UpdateLoisirsSubjects < ActiveRecord::Migration
  def up
    # ------------------------------
    # Loisirs creatifs
    # ------------------------------

    dessin_peinture_arts = rename_subject('loisirs-creatifs', 'Dessin, Peinture & Arts plastiques')

    papier_impression = rename_subject 'serigraphie', 'Papier & Impression'
    papier_impression.children.create name: 'Sérigraphie'

    deco        = rename_subject 'deco-bricolage', 'Déco, Mode & Bricolage'
    objets_deco = rename_subject 'encadrement', 'Objets & décoration'
    objets_deco.children.create name: 'Encadrement'
    update_parent 'cannage-paillage', objets_deco
    objets_deco.parent = deco
    objets_deco.save

    ateliers_de_loisirs_creatifs = Subject.friendly.find 'ateliers-de-loisirs-creatifs'
    ateliers_de_loisirs_creatifs.courses.each do |c|
      c.subjects.delete(ateliers_de_loisirs_creatifs)
      c.subjects << deco
      c.save
    end
    ateliers_de_loisirs_creatifs.destroy

    update_parent 'bougies', 'objets-decoration'
    update_parent 'cartonnage', 'objets-decoration'
    update_parent 'fabrication-de-meubles-en-carton', 'objets-decoration'

    origami = Subject.friendly.find 'origami-papier'
    origami.children.each do |child|
      child.parent = papier_impression
      child.save
    end
    origami.destroy

    couture = Subject.friendly.find 'couture-creation-textile'
    couture.parent = deco
    couture.save

    ['creation-de-bijoux', 'creation-de-poupees', 'decoration-de-table-fete', 'fleurs-pressees', 'lampes-abat-jour', 'masques', 'modelisme-maquettes', 'mosaique-decorative', 'peinture-sur-porcelaine', 'peinture-sur-soie-tissus', 'peinture-sur-verre', 'techniques-du-pochoir'].each do |subj_name|
      subj        = Subject.friendly.find subj_name
      subj.parent = objets_deco
      subj.save
    end

    update_parent 'techniques-du-pochoir', papier_impression
    pochoirs        = Subject.friendly.find 'refection-de-sieges-fauteuils'
    pochoirs.parent = objets_deco
    pochoirs.save

    vannerie_paniers        = Subject.friendly.find 'vannerie-paniers'
    vannerie_paniers.parent = objets_deco
    vannerie_paniers.save

    update_parent 'scrapbooking-albums', papier_impression
    delete_subject 'scrapbooking'

    ########################### Ligne 35
    travail_de_la_matière_restauration = rename_subject 'art-du-metal', 'Travail de la matière & Restauration'

    rename_subject 'fonderie-bronze-moulages', 'Art du métal'

    ['couteaux-coutellerie', 'fonderie', 'forge-forgeron', 'sculpture-sur-metal'].each do |subj_name|
      s = Subject.friendly.find subj_name
      s.destroy
    end
    travail_resto = update_parent 'art-du-tissu', 'travail-de-la-matiere-restauration'
    delete_subject "couture-broderie-d-art"
    update_parent 'art-du-tissu', travail_resto

    delete_subjects ['feutre-laine', 'teintures-vegetales-naturelles', 'tissage-tapisserie-d-art']

    rename_subject "art-vegetal", 'Art floral & végétal'

    delete_subject 'crayon'

    dessin_peinture        = Subject.friendly.find 'dessin-peinture'
    dessin_peinture.children.create name: 'Autres arts plastiques'
    ['croquis', 'decouverte-dessin-peinture', 'copie-de-tableaux', 'crayon-mine-fusain', 'aquarelle-lavis', 'bande-dessinee', 'dessin--2', 'caricature', 'dessin-a-l-encre-plume', 'gravure', 'graffiti', 'manga', 'pastel', 'peinture', 'peinture-a-l-huile', 'peinture-acrylique', 'peinture-abstraite-contemporaine', 'peinture-d-icones', 'peinture-en-trompe-l-oeil', 'enluminure'].each do |slug|
      subject = Subject.friendly.find(slug)
      subject.parent = dessin_peinture
      subject.save
    end

    update_parent 'ebenisterie', 'travail-de-la-matiere-restauration'
    rename_subject 'ebenisterie', "Travail du bois & du cuir"

    update_parent 'vitrail-fusing-dalle-verre', 'travail-de-la-matiere-restauration'
    rename_subject 'vitrail-fusing-dalle-verre', "Vitrail & travail du verre"

    update_parent 'patines-ceruses-dorures', 'travail-de-la-matiere-restauration'
    rename_subject 'patines-ceruses-dorures', "Restauration d'art"

    rename_subject "dessin-d-apres-modele-vivant", "Dessin ou peinture d'après modèle vivant"

    update_parent 'mosaique-ancienne-artistique', 'sculpture-taille'
    delete_subject 'mosaique-d-art'

    update_parent  'ikebana', 'art-floral-vegetal'
    delete_subject 'art-floral'
    caligraphie = rename_subject 'calligraphie', "Ateliers d'écriture & Calligraphie"
    caligraphie.children.create name: "Ateliers d'écriture"

    delete_subjects ['patines', 'restauration-de-mobilier-ancien', 'restauration-de-tableaux', 'vernis-au-tampon', 'fabrication-d-objets-en-bois', 'peinture-sur-bois-icones', 'sculpture-sur-bois', 'travail-du-cuir-et-des-peaux', 'travail-du-verre', 'pate-de-verre', 'perles-de-verre', 'souffleur-de-verre', 'vitrail', 'art-visuel', 'art-numerique', 'ecoles-centres-academies-de-musique', 'arts-plastiques', 'travail-du-cuir', 'travail-du-bois', 'vitrail-travail-du-verre', 'restauration-d-art']
    art_artisanat   = Subject.friendly.find('art-artisanat')
    art_artisanat.children.each do |child|
      child.parent = dessin_peinture_arts
      child.save
    end
    art_artisanat.destroy

    ateliers_ecriture_calligraphie = rename_subject('ateliers-d-ecriture', "Ateliers d'écriture & Calligraphie")
    ateliers_ecriture = rename_subject 'ecriture-jeunesse'  , "Ateliers d'écriture"
    ateliers_ecriture.parent = ateliers_ecriture_calligraphie
    ateliers_ecriture.save
    ateliers_ecriture_calligraphie.children.create name: "Ateliers d'écriture"
    delete_subjects ['ecriture-journalistique', 'ecriture-theatrale--2', 'lettres-correspondance', 'poesie', 'carnets-de-voyage', 'ecriture-autobiographique', 'ecriture-de-biographies-memoires', 'ecriture-de-chansons', 'ecriture-de-contes', 'ecriture-de-nouvelles', 'ecriture-de-scenarios', 'ecriture-decouverte', 'ecriture-de-polars', 'ecriture-de-science-fiction', 'ecriture-de-romans']
    delete_subject 'ateliers-d-ecriture-calligraphie--2'
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
