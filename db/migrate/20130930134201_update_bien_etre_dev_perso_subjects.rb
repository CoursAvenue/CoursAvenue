# encoding: utf-8
class UpdateBienEtreDevPersoSubjects < ActiveRecord::Migration
  def up
    yoga_bien_etre_sante = rename_subject 'bien-etre-sante', 'Yoga, Bien-être & Santé'
    dev_personnel = update_parent 'dev-personnel', yoga_bien_etre_sante
    delete_subjects ['astrologie', 'numerologie', 'astrologie-numerologie']
    rename_subject 'coaching', 'Coaching personnel'
    delete_subjects ['life-coaching', 'coaching-professionnel']
    delete_subjects ['estime-de-soi-confiance', 'gestion-du-stress', 'hypnose', 'pensee-positive', 'pnl', 'rencontres', 'gestion-des-dependances', 'gestion-des-peurs-et-phobies', 'parler-en-public']
    update_parent 'ecoles-de-rire', dev_personnel
    delete_subject 'rire-clown'
    update_parent 'psychotherapies', dev_personnel
    delete_children 'psychotherapies'
    delete_children 'spiritualites'
    delete_children 'tarots-tirages'
    delete_subject 'acupuncture'

    therapie = update_parent 'art-therapie', yoga_bien_etre_sante
    delete_children 'art-therapie'
    therapie.name = 'Thérapies'
    therapie.save
    delete_subject 'balneo-thalasso'
    update_parent 'therapies', yoga_bien_etre_sante
    update_parent 'feng-shui-bien-etre', therapie
    update_parent 'geobiologie-magnetisme', therapie
    delete_children 'geobiologie-magnetisme'
    therapie.children.create name: 'Art-thérapies'
    delete_subject 'jeune'

    sante = yoga_bien_etre_sante.children.create name: 'Santé'
    update_parent 'massage', sante
    delete_children 'massage'
    update_parent 'medecines-alternatives', sante
    delete_children 'medecines-alternatives'
    update_parent 'nutrition', sante
    delete_children 'nutrition'
    update_parent 'reflexologie', sante
    delete_children 'reflexologie'
    update_parent 'reiki', sante
    delete_children 'reiki'
    sante.children.create name: 'Alimentation & diététique'

    delete_subject 'eveil-corporel'
    eveil_corporel = rename_subject 'relaxation-eveil-corporel', 'Eveil corporel'
    eveil_corporel.children.create name: 'Autres méthodes'

    relaxation = yoga_bien_etre_sante.children.create name: 'Relaxation'
    relaxation_detente = update_parent 'relaxation-detente', relaxation
    relaxation.children.create name: 'Relaxation autres'
    update_parent 'watsu', relaxation
    update_parent 'shiatsu', relaxation
    update_parent 'tai-chi-chuan', relaxation
    rename_subject 'tai-chi-chuan', 'Tai Chi Chuan'
    update_parent 'qi-gong', relaxation
    rename_subject 'yoga-hatha-yoga', 'Hatha yoga'
    delete_subject 'shiatsu-watsu'
    delete_subject 'tai-chi-qi-gong'
    yoga = Subject.friendly.find 'yoga'
    yoga.children.create name: 'Ashtanga Vinyasa yoga'
    yoga.children.create name: 'Bikram yoga'
    yoga.children.create name: 'Kundalini yoga'
    yoga.children.create name: 'Power yoga'
    yoga.children.create name: 'Yoga Nidra'
    yoga.children.create name: 'Iyengar yoga'
    yoga.children.create name: 'Yoga autres'
    rename_subject 'enneagramme', 'Estime de soi & confiance'
  end

  def down
  end

  def rename_subject slug, new_name
    subject      = Subject.friendly.find slug
    subject.name = new_name
    subject.save
    return subject
  end

  def delete_children slug
    subject      = Subject.friendly.find slug
    subject.children.map(&:destroy)
  end

  def delete_subject slug
    subject      = Subject.friendly.find slug
    subject.children.map(&:destroy)
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
