# encoding: utf-8
class UpdateTheatreSubjects < ActiveRecord::Migration
  def up
    # Danse
    delete_subject 'danses-de-couple'
    salsa = Subject.find 'salsa'
    salsa_structures = salsa.structures
    salsa.destroy
    danse = Subject.find 'danse'
    update_parent 'danses-urbaines', danse
    update_parent 'jazz-street-jazz-modern-jazz', 'danses-urbaines'
    delete_subjects ['jazz-modern-jazz']
    rock_swing = rename_subject 'rock-danses-de-salon', 'Danses Rock-swing'
    rock_swing.children.create name: 'Charleston'
    rock_swing.children.create name: 'Shag'
    rock_swing.children.create name: 'Balboa'
    rock_swing.children.create name: 'Boogie-woogie'
    latine = danse.children.create name: 'Danses de salon & latines'
    update_parent 'valse-slow-fox-quick-step', latine
    rename_subject 'valse-slow-fox-quick-step', 'Valse, Java & Polka'
    latine.children.create name: 'Quick step, Slowfox, Foxtrot, Boston, Charleston & Madison'
    update_parent 'danses-de-societes', latine
    rename_subject 'danses-de-societes', 'Autres danses de société'
    update_parent 'danses-sportives', latine
    rename_subject 'danses-sportives', 'Danses sportives standards & latines'
    update_parent 'rock-n-roll', rock_swing
    delete_subjects ['swing', 'valse']
    # rename_subject 'samba-danses-bresiliennes', 'Tango, Chachacha, Samba, Forro & Mambo'
    delete_subject 'samba-danses-bresiliennes'
    delete_subject 'tango'
    other_danse = danse.children.create name: 'Autres danses'
    update_parent 'pole-dance', other_danse
    update_parent 'fusion', other_danse
    danse_classique_and_cont = rename_subject 'danse-classique', 'Danse classique & contemporaine'
    danse_classique = danse_classique_and_cont.children.create name: 'Danse classique'
    update_parent 'diverses-danses', danse_classique_and_cont
    rename_subject 'diverses-danses', 'Diverses danses classiques & contemporaines'
    update_parent 'danse-contemporaine-moderne', danse_classique_and_cont
    delete_subjects ['ragga', 'street', 'danse-contemporaine']
    update_parent 'comedie-musicale-choregraphies', other_danse
    rename_subject 'comedie-musicale-choregraphies', 'Comédie musicale & chorégraphies'
    update_parent 'barre-au-sol-classique', danse_classique_and_cont
    update_parent 'barre-au-sol-contemporaine', danse_classique_and_cont
    delete_subject 'barre-au-sol-assouplissements'
    update_parent 'ateliers-corps-mouvement', 'eveil-corporel'
    delete_subject 'corps-mouvement'
    update_parent 'dance-floor-varietes', 'danses-urbaines'
    delete_subject 'dance-floor'
    update_parent 'danse-orientale', 'danses-du-monde'
    update_parent 'danse-africaine-afro-jazz', 'danses-du-monde'
    delete_subject 'danse-africaine'
    delete_subject 'ecoles-de-danses'
    update_parent 'danses-folkloriques-traditionnelles', other_danse
    update_parent 'danse-country', other_danse
    delete_subject 'danses-folkloriques-traditionnelles--2'
    delete_subject 'danse-fitness'
    update_parent 'flamenco', 'danses-du-monde'
    update_parent 'rumba-paso-doble-jiive', latine
    salsa = update_parent 'salsa-bachata-chacha', latine
    salsa_structures.map{|structure| structure.subjects << salsa; structure.save}
    update_parent 'zouk-lambazouk-merengue', latine
    rename_subject 'zouk-lambazouk-merengue', 'Merengue, Zouk & Lambada'
    update_parent 'danse-des-5-rythmes-biodanza-danse-therapie', 'eveil-corporel'
    delete_subject 'rumba'
    update_parent 'blues-west-coast', rock_swing
    update_parent 'danse-de-couple-afro-latines', latine
    rename_subject 'danse-de-couple-afro-latines', 'Tango, Chachacha, Samba, Forro & Mambo'
    delete_subject 'zouk'
    delete_subject 'coupe-decale'
    delete_subject 'forro-bresilien-samba'
    rename_subject 'danses-folks-et-traditionnelles', 'Danses folks, de caractère & traditionnelles'
    delete_subject 'danse-des-5-rythmes'
    update_parent 'feldenkrais-alexander', 'eveil-corporel'
    rename_subject 'feldenkrais-alexander', 'Technique Alexander'
    update_parent 'claquettes', other_danse
    update_parent 'zumba', 'danses-urbaines'


    # Théâtre
    theatre_scene = Subject.create name: 'Théâtre & Scène'
    theatre = update_parent 'theatre', theatre_scene
    cirque = update_parent 'cirque-arts-de-la-rue', theatre_scene
    cirque.children.create name: 'Voltige'
    rename_subject 'decouverte-du-theatre', 'Théâtre amateurs'

    lecture = update_parent 'lecture', 'theatre-scene'

    son_et_lumiere = update_parent 'son-lumiere', 'theatre-scene'
    son_et_lumiere.children.create name: 'Eclairage & sonorisation'
    son_et_lumiere.children.create name: 'Préparation à la scène / aux concerts'
    son_et_lumiere.children.create name: 'Prise de son & montage audio'
    son_et_lumiere.children.create name: 'Radio'

    delete_subject 'mode-beaute'

    subj = Subject.find 'objets-decoration'
    subj.children.create name: 'Vannerie & paniers'
    subj = Subject.find 'art-floral-vegetal'
    subj.children.create name: 'Créations florales'
  end

  def down
  end
  def rename_subject slug, new_name
    subject      = Subject.find slug
    subject.name = new_name
    subject.save
    return subject
  end

  def delete_subject slug
    subject      = Subject.find slug
    subject.destroy
  end

  def delete_subjects slugs
    slugs.each do |slug|
      delete_subject(slug)
    end
  end

  def update_parent slug, parent_slug
    child  = Subject.find(slug)
    if parent_slug.is_a? String
      parent = Subject.find(parent_slug)
    else
      parent = parent_slug
    end
    child.parent = parent
    child.save
    return child
  end
end
